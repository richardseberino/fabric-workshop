/*
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Contract } = require('./node_modules/fabric-contract-api');
const Auxiliar = require('./auxiliar');
const Dispositivo = require('./dispositivo');

class Chaincode extends Contract {

    // Método que é chamado para a instanciação do Blockchain
    async initLedger(ctx) {
        console.info('============= INÍCIO : INICIANDO LEDGER ===========');
    }
    /**
     * Registro de uma nova qualificação para o dispositivo.
     * Verifica o motivo para desativar o dispositivo caso necessário.
     * @param {ChaincodeCtx} ctx Enviado automaticamente pela biblioteca fabric-network
     * @param {[String]} imei hash SHA-256 (64 caracteres)
     * @param {[String]} iccid hash SHA-256 (64 caracteres)
     * @param {[String]} msisdn hash SHA-256 (64 caracteres)
     * @param {[String]} motivo  número motivo (de acordo com a tabela)
     * @param {[String]} descricao (opcional) descricao do motivo da qualificacao
     * @param {[String]} numeroReferenciaIF  (opcional) Número de controle interno utilizado pela Instituição Financeira
     * @param {[String]} ispb campo exclusivo da CIP
     * @param {[String]} assinatura campo exclusivo da CIP
     * @param {[String]} idCertificado campo exclusivo da CIP
     * @returns {[JSON]} Dispositivo
     */
    async qualificaDispositivo(ctx, imei, iccid, msisdn, motivo, descricao, numeroReferenciaIF, ispb, assinatura, idCertificado, chavePublica) {

        try {
            //console.info('============= INICIO : Qualificar Dispositivo ===========')
            //Verificando  campos obrigatorios
            if (arguments.length != 11 || !imei || !iccid || !msisdn || !motivo) throw new Error("Faltando argumentos!");

            //transformando valores para hash
            imei = Auxiliar.transformarHash(imei)
            iccid = Auxiliar.transformarHash(iccid)
            msisdn = Auxiliar.transformarHash(msisdn)

            //Gerando ID do dispositivo baseado nos hashes enviados
            const idDispositivo = Auxiliar.concatenaHash(imei, iccid, msisdn);

            // verificar se dispositivo ja foi cadastrado anteriormente para tratar a dataDeCriacao
            let bufferDispositivo = ((await ctx.stub.getState(idDispositivo)) || Buffer.from([]));

            let dataCriacao = undefined
            // Se o data nao vier vazio, o dispositivo ja foi cadastrado e sera pego sua data de criacao
            if (!JSON.stringify(bufferDispositivo).includes('"data":[]')) {

                let dispositivoPego = JSON.parse(bufferDispositivo)
                dataCriacao = dispositivoPego.dataCriacao
            }

            //ISPB será preenchido abaixo.
            let dispositivo = new Dispositivo(imei, iccid, msisdn, motivo, descricao, numeroReferenciaIF, dataCriacao, ispb, assinatura, idCertificado, chavePublica)


            //Extraindo MSPID
            var mspid = Auxiliar.extrairMSPID(ctx.stub)
            //O mspid é usado para identificar o PEER que está realizando a transação
            //O Peer da CIP tem permissão para inserir campos exclusivos usados para 
            //identificar Entidades que estão acessando a rede por meio da REST-API
            if (mspid == "ISPB04391007") {
                if (!ispb || !assinatura || !idCertificado || !chavePublica) throw new Error("Argumentos reservados para CIP faltando")
                dispositivo.ispb = ispb
                dispositivo.assinatura = assinatura
                dispositivo.idCertificado = idCertificado
                dispositivo.chavePublica = chavePublica
            } else {
                //Todas as demais entidas são obrigadas a registrar os ispb usando o MSPID
                // tratamento de string por regra de negocio, só pegar os numeros depois da palavra ISPB,
                // ex: ISPB00888 = 008888
                let ispbTratado = mspid.substring(4);

                dispositivo.ispb = ispbTratado
                ispb = ispbTratado

                //Campos reservados apenas para CIP se manterão vazios para os demais peers
                dispositivo.assinatura = ""
                dispositivo.chavePublica = ""
                dispositivo.idCertificado = ""
            }
            //Registrando a qualificação do dispositivo na rede
            await ctx.stub.putState(dispositivo.idDispositivo, Auxiliar.jsonParaBytes(dispositivo.paraJSON()))

            console.log(`Método: qualificaDispositivo | ISPB: ${ispb} | Código de retorno 0`);
            return {
                mensagem: "SUCESSO",
                codigo: "0",
                dado: dispositivo.paraJSON()
            }

        } catch (erro) {

            let ispbTratado = Auxiliar.extrairMSPID(ctx.stub).split('B')[1]
            let ISPB = ispb == undefined ? ispbTratado : ispb

            console.log(`Método: qualificaDispositivo | ISPB: ${ISPB} | Código de retorno -99`);
            return {
                mensagem: erro.toString(),
                codigo: "-99",
                dado: {}
            }
        }
    }


    /**
     * Consulta a ultima qualificacao de um dispositivo. 
     * Caso não exista um estado ativo do dispositivo retorna codigo -99 
     * @param {*} ctx Enviado automaticamente pela biblioteca fabric-network
     * @param {*} imei hash SHA-256 (64 caracteres)
     * @param {*} iccid hash SHA-256 (64 caracteres)
     * @param {*} msisdn hash SHA-256 (64 caracteres)
     */
    async consultaDispositivo(ctx, imei, iccid, msisdn) {

        try {
            //Verificando parametros obrigatorios
            if (!ctx || !imei || !iccid || !msisdn) throw new Error("Faltando Argumentos!")


            imei = Auxiliar.transformarHash(imei)
            iccid = Auxiliar.transformarHash(iccid)
            msisdn = Auxiliar.transformarHash(msisdn)

            //Verify hash idParams and generate asset key
            const idDispositivo = Auxiliar.concatenaHash(imei, iccid, msisdn);

            //Receive Buffer of Asset from Ledger
            //let bufferDispositivo = await ctx.stub.getState(idDispositivo);
            let bufferDispositivo = ((await ctx.stub.getState(idDispositivo)) || Buffer.from([]));

            let dispositivo = undefined
            if (!JSON.stringify(bufferDispositivo).includes('"data":[]')) dispositivo = JSON.parse(bufferDispositivo);

            //O retorno será vazio quando não hover registro do device ou seu ultimo estado for um desqualificador (motivo 4).
            if (dispositivo == undefined || dispositivo.motivo == "4") return {
                mensagem: "Dispositivo não encontrado",
                codigo: "0",
                dado: {}
            }

            console.log(`Método: consultaDispositivo | idDispositivo: ${idDispositivo} | Código de retorno 0`);
            return {
                mensagem: "SUCESSO",
                codigo: "0",
                dado: dispositivo
            }
        }
        catch (erro) {
            console.log(`Método: consultaDispositivo | idDispositivo: ${imei + iccid + msisdn} | Código de retorno -99`);
            return {
                mensagem: erro.toString(),
                codigo: "-99",
                dado: {}
            }
        }
    }
    /**
     * Recupera o histórico de qualificacoes de um dispositivo do ledger
     * @param {ChaincodigoCtx} ctx Enviado automaticamente pela biblioteca fabric-network
     * @param {[String]} imei hash SHA-256 (64 caracteres)
     * @param {[String]} iccid hash SHA-256 (64 caracteres)
     * @param {[String]} msisdn hash SHA-256 (64 caracteres)
     * @returns {[JSON]} Dispositivo Historico
     */
    async consultaHistoricoDispositivo(ctx, imei, iccid, msisdn) {

        try {
            //Verificando campos obrigatorios
            if (!ctx || !imei || !iccid || !msisdn) throw new Error("Faltando Argumentos!")

            //gerando hashes
            imei = Auxiliar.transformarHash(imei)
            iccid = Auxiliar.transformarHash(iccid)
            msisdn = Auxiliar.transformarHash(msisdn)
            //gerando chave
            const idDispositivo = Auxiliar.concatenaHash(imei, iccid, msisdn);

            // Recuperando Historico do dispositivo
            let resultadosIterador = await ctx.stub.getHistoryForKey(idDispositivo);
            // Extraindo Iterador
            const historicoDispositivo = resultadosIterador != undefined ? await Auxiliar.iteradorParaJSON(resultadosIterador, true) : []
            console.log(`Método: consultaHistoricoDispositivo | idDispositivo: ${idDispositivo} | Código de retorno 0`);

            let mensagem = undefined
            let historico = JSON.parse(JSON.stringify(historicoDispositivo))

            if (historico.length > 0) mensagem = "SUCESSO"
            else mensagem = "Dispositivo não enocntrado"

            return {
                mensagem: mensagem,
                codigo: "0",
                historico: historico
            }


        } catch (erro) {
            console.log(`Método: consultaHistoricoDispositivo | idDispositivo: ${imei + iccid + msisdn} | Código de retorno -99`);
            return {
                mensagem: erro.toString(),
                codigo: "-99",
                historico: {}
            }
        }
    }

}

module.exports = Chaincode;

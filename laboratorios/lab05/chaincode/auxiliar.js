const eventos = require('./eventos')
const ClientIdentity = require('fabric-shim').ClientIdentity;
var sha256 = require('sha-256-js');

class Auxiliar{

    // static verificaEConcatenaHashes(imei, iccid, msisdn){
    //     if(imei.length === 64 && iccid.length === 64 && msisdn.length === 64){
    //         var concatenacao = imei + iccid + msisdn
    //         var regex = new RegExp('^[A-Fa-f0-9]{192}$');
    //         if (regex.test(concatenacao)) return (imei + iccid + msisdn)
    //         else throw new Error("As entradas deve ser hashes hexadecimais SHA-256")
            
    //     }
    //     else{
    //         throw new Error("As entradas deve ser hashes hexadecimais SHA-256")
    //     }
    // }

    static transformarHash(valor){
        return sha256(valor)
    }

    static concatenaHash(imei, iccid, msisdn){
        return imei+iccid+msisdn
    }


    static jsonParaBytes(resposta){
        let resultado = JSON.stringify(resposta);
        return Buffer.from(resultado);
    }

    static async iteradorParaJSON(iterador, historico) {
        let vetorResultado = [];
        while (true) {
            let resposta = await iterador.next();
            if (resposta.value && resposta.value.value.toString()) {
                let jsonResposta = {};
                if (historico && historico === true) {
                    jsonResposta.TxId = resposta.value.tx_id;
                    jsonResposta.dataTransacacao = new Date(resposta.value.timestamp.seconds.low*1000 - (1000 * 60 * 60 * 3));
                    try {
                        jsonResposta.dado = JSON.parse(resposta.value.value.toString('utf8'));
                    } catch (erro) {
                        console.log(erro);
                        jsonResposta.dado = resposta.value.value.toString('utf8');
                    }
                } else {
                    jsonResposta.Chave = resposta.value.key;
                    try {
                        jsonResposta.Registro = JSON.parse(resposta.value.value.toString('utf8'));
                    } catch (erro) {
                        jsonResposta.Registro = resposta.value.value.toString('utf8');
                    }
                }
                vetorResultado.push(jsonResposta);
            }
            if (resposta.done) {
                await iterador.close();
                return vetorResultado;
            }
        }
    }

    static verificaMotivo(motivo){
        if(eventos.hasOwnProperty(motivo))   return motivo
        else throw new Error("Motivo não encontrado")
    }

    static extrairMSPID(stub){
        if(!stub.txId) return "TEST_ISPB11111"
        let _clientIdentity = new ClientIdentity(stub);
        let mspid = _clientIdentity.getMSPID();
        // tratamento do MSPID , regras de neogio
        //
        if(mspid) {
            return mspid
        }

        return null
    } 

}

module.exports = Auxiliar
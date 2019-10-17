const Auxiliar = require('./auxiliar')


class Dispositivo {
    constructor(imei, iccid, msisdn, motivo, descricao, numeroReferenciaIF, dataCriacao, ispb, assinatura, idCertificado, chavePublica) {
        this.idDispositivo = Auxiliar.concatenaHash(imei, iccid, msisdn)
        this.motivo = Auxiliar.verificaMotivo(motivo)
        this.numeroReferenciaIF = numeroReferenciaIF ? numeroReferenciaIF : ""
        this.ispb = ispb ? ispb : ""
        this.dataCriacao = dataCriacao ? dataCriacao : new Date(Date.now() - 1000 * 60 * 60 * 3)
        this.dataAtualizacao = new Date(Date.now() - 1000 * 60 * 60 * 3)
        this.imei = imei
        this.iccid = iccid
        this.msisdn = msisdn
        this.assinatura = assinatura ? assinatura : ""
        this.idCertificado = idCertificado ? idCertificado : ""
        this.descricao = descricao ? descricao : ""
        this.chavePublica = chavePublica ? chavePublica : ""
    }

    paraJSON() {
        return {
            idDispositivo: this.idDispositivo,
            motivo: this.motivo,
            descricao: this.descricao,
            numeroReferenciaIF: this.numeroReferenciaIF,
            ispb: this.ispb,
            imei: this.imei,
            iccid: this.iccid,
            msisdn: this.msisdn,
            dataCriacao: this.dataCriacao,
            dataAtualizacao: this.dataAtualizacao,
            assinatura: this.assinatura,
            idCertificado: this.idCertificado,
            chavePublica: this.chavePublica
        }
    }
}

module.exports = Dispositivo
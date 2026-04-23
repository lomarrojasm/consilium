class QuotationMailer < ApplicationMailer
  default from: "notificaciones@consiliumconsultoria.com"

  def send_quote(quotation)
    @quotation = quotation
    @client = quotation.client
    @project = quotation.project

    # Suponiendo que tu modelo Client tiene un sponsor_email
    mail(to: @client.sponsor_email, subject: "Consilium: Autorización requerida para facturación (#COT-#{@quotation.id})")
  end

  def quote_authorized(quotation)
    @quotation = quotation
    @client = quotation.client

    # Avisar a los administradores de finanzas
    mail(to: "finanzas@consilium.mx", subject: "¡Cotización Aprobada! Lista para facturar: #{@client.company_name}")
  end

  def send_invoice(quotation)
    @quotation = quotation
    @client = quotation.client
    @project = quotation.project

    # Adjuntamos físicamente los archivos al correo
    if @quotation.invoice_pdf.attached?
      attachments[@quotation.invoice_pdf.filename.to_s] = @quotation.invoice_pdf.download
    end

    if @quotation.invoice_xml.attached?
      attachments[@quotation.invoice_xml.filename.to_s] = @quotation.invoice_xml.download
    end

    mail(to: @client.sponsor_email, subject: "Factura Emitida - Proyecto: #{@project.name}")
  end
end

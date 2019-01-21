module SemiStatic
  class OrderMailer < ActionMailer::Base
    def order_notification(order)
      subject = 'Product order notification'
      email = SemiStatic::Engine.config.contact_email

      @contact = order.customer
      @host = SemiStatic::Engine.config.mail_host
      @url = order_url(order, :host => URI.parse(SemiStatic::Engine.config.localeDomains[order.order_items.first.product.entry.locale]).host)
      @locale = :en
      @order = order
      mail(:from => SemiStatic::Engine.config.mailer_from, :to => email, :subject => subject)
    end
  end
end

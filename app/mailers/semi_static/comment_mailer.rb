module SemiStatic
  class CommentMailer < ActionMailer::Base
    def comment_notification(comment)
      subject = "New comment added to blog by #{comment.email}: #{comment.name}"
      email = SemiStatic::Engine.config.has?('comment_email') || SemiStatic::Engine.config.has?('contact_email')

      @comment = comment
      @host = URI.parse(SemiStatic::Engine.config.localeDomains[@comment.entry.tag.locale]).host
      @locale = :en
      mail(:from => SemiStatic::Engine.config.mailer_from, :to => email, :subject => subject)
    end
  end
end

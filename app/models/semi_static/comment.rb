module SemiStatic
  class Comment < ActiveRecord::Base
    attr_accessible :body, :name, :email, :entry_id, :status, :company, :agreed, :captcha, :captcha_code
    attr_accessor :captcha, :captcha_code

    belongs_to :entry

    validates_presence_of :email

    before_create :check_captcha
    after_create :check_strategy

    #
    # Thus is a very simple formula, you may want to make yours more complex
    # but in our experience spammers don't invest much time in figuring these
    # things out.
    #
    # FWIW the formula is reverse the order then subtract 2 from each digit, eg:
    # '7388' => '8837' => '6615' 
    #
    #
    def check_captcha
      if (@captcha_code != @captcha.reverse.split(//).collect{|n| (((n.to_i + 10) - 2).modulo(10)).to_s}.join)
        errors.add(:captcha, "Your numbers do not match the numbers in the image")
        false
      end
    end

    def check_strategy
      send_email
    end

    def send_email
      SemiStatic::CommentMailer.comment_notification(self).deliver
    end
  end
end

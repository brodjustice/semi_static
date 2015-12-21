module SemiStatic
  module NewslettersHelper
    def salutation_name(newsletter, subscriber = nil)
      if subscriber.respond_to?('fullname')
        case newsletter.salutation_type
        when SemiStatic::Newsletter::SALUTATION_TYPES[:first_name]
          @subscriber.name
        when SemiStatic::Newsletter::SALUTATION_TYPES[:full_name]
          @subscriber.fullname
        end
      else
        case newsletter.salutation_type
        when SemiStatic::Newsletter::SALUTATION_TYPES[:first_name]
          'Firstname'
        when SemiStatic::Newsletter::SALUTATION_TYPES[:full_name]
          'Firstname Surname'
        end
      end
    end
  end
end

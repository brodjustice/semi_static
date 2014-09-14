module SemiStatic
  module ApplicationHelper
    def _(*args);  I18n.t(*args); end
  end
end

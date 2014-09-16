module SemiStatic
  module EntriesHelper
    STYLE_CLASSES = ['normal', ' feint',  'flat',  'collapse', 'flat collapse', 'hard', 'highlight']

    def entry_summary(e, l = 300)
      if e.summary.blank?
        truncate_html(e.body, :length => l)
      else
        simple_format(e.summary)
      end
    end

  end
end

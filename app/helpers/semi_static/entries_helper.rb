module SemiStatic
  module EntriesHelper
    STYLE_CLASSES = ['normal', ' feint',  'flat',  'collapse', 'flat collapse', 'hard', 'highlight', 'dotted']

    def entry_summary(e, l = 300)
      if e.summary.blank?
        truncate_html(e.body, :length => l)
      else
        simple_format(e.summary)
      end
    end

    def youtube_video(id)
      "<div class='yt_video'> <iframe width='640' height='360' src='//www.youtube.com/embed/#{id}' frameborder='0' allowfullscreen></iframe></div>".html_safe
    end
  end
end

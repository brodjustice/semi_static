module SemiStatic
  module EntriesHelper
    STYLE_CLASSES = ['normal', ' feint',  'flat',  'collapse', 'flat collapse', 'hard', 'highlight', 'wobble', 'dotted']

    def youtube_video(id)
      "<div class='yt_video'> <iframe width='640' height='360' src='//www.youtube.com/embed/#{id}?rel=0&amp;controls=0&amp;showinfo=0' allowfullscreen></iframe></div>".html_safe
    end

    def human_file_size(s)
      units = %w{b Kb Mb Gb Tb}
      e = (Math.log(s)/Math.log(1024)).floor
      s = "%.0f" % (s.to_f / 1024**e)
      s.sub(/\.?0*$/, units[e])
    end
  end
end

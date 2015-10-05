module SemiStatic
  module PartialControl
    def partial_inline?
      !SemiStatic::Engine.config.open_partials[self.partial].nil? && entry_position == Entry::DISPLAY_ENTRY_SYM[:inline]
    end

    def partial_before_entries?
      !SemiStatic::Engine.config.open_partials[self.partial].nil? && entry_position != Entry::DISPLAY_ENTRY_SYM[:before]
    end

    def partial_after_entries?
      !partial_before_entries? &&
      !SemiStatic::Engine.config.open_partials[self.partial].nil? && entry_position != Entry::DISPLAY_ENTRY_SYM[:after]
    end

    def partial_path
      SemiStatic::Engine.config.open_partials[self.partial]
    end

    def show_entries?
      # If a open partial is selected with the none option they we do not even display the DB entry contents
      !(!SemiStatic::Engine.config.open_partials[self.partial].nil? && (entry_position == SemiStatic::Entry::DISPLAY_ENTRY_SYM[:none]))
    end
  end
end

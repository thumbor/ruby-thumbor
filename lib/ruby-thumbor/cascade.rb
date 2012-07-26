require 'digest/md5'

module Thumbor
  module Cascade
    def image image_option
      @image                  = image_option
      glue :image_hash, Digest::MD5.hexdigest(image_option)
    end

    def meta
      glue :meta
    end

    def fit_in
      glue :fit_in, 'fit-in'
    end

    def crop crop_options
      return self if  not crop_options or
      not crop_options.length == 4 or
      not crop_options.reduce(:+).nonzero?

      crop_left, crop_top, crop_right, crop_bottom = crop_options
      glue :crop, "#{crop_left}x#{crop_top}:#{crop_right}x#{crop_bottom}"
    end

    def size options
      return self unless (options.keys & [:width, :height, :flip, :flop]).any?

      options               = {:width => 0, :height => 0}.merge(options)
      width, height         = options[:width].to_s, options[:height].to_s
      has_width, has_height = width.to_i.nonzero?, height.to_i.nonzero?

      width  = width.insert  0, '-' if options[:flip]
      height = height.insert 0, '-' if options[:flop]

      glue :size, "#{width}x#{height}"
    end

    def halign alignment
      glue :halign, alignment, :if => [:left, :right].include?(alignment)
    end

    def valign alignment
      glue :valign, alignment, :if => [:top, :bottom].include?(alignment)
    end

    def smart
      glue :smart
    end

    def filters filter_options
      glue  :filters,
        "filters:#{ [*filter_options].join(':') }",
      :if => (filter_options and filter_options.any?)
    end

    def image_hash
      @image_hash = true
      self
    end

    private
    def glue part, value = nil, options = {:if => true}
      @url_parts[part.to_sym] = (value or part.to_s) if options[:if]
      self
    end
  end

end


def ranges_overlap?(range_a, range_b)
  range_b.begin <= range_a.end && range_a.begin <= range_b.end
end
class Range
  def intersection(other)
    return nil if (self.max < other.begin or other.max < self.begin)
    [self.begin, other.begin].max..[self.max, other.max].min
  end
  alias_method :&, :intersection
end

# 06/20: Solstice d'été
# 12/21: Solstice d'hiver
Event = Struct.new(:from, :to, :name, :color) do
  def overlap?(range)
    # (from..to).overlap?(range)
    ranges_overlap?((from..to), range)
  end

  def range
    (from..to)
  end

  def style_size(container_range)
    css = '';
    inside_range = container_range.intersection(range)
    size = range_size(inside_range)
    container_range_size = range_size(container_range)
    css += "height: #{size.to_f/container_range_size.to_f*100}%;" if (size != 0)
    css
  end

  def image
    path = "img/rotated/#{name.strip.downcase}.jpg"
    return path if File.exist?(Rails.root + "public/#{path}")
    nil
  end

  def line_style(events)
    "width: #{events.filter{|e| e.from > from || (e.from == from && e.name >= name) }.filter{|e| e.overlap?(range)}.length * 2}em"
  end

  def style(container_range)
    "#{style_size(container_range)}#{style_offset(container_range)}"
  end

  def range_size(range)
    range.end.to_time.end_of_day.to_i - range.begin.to_time.beginning_of_day.to_i
  end

  def style_offset(container_range)
    inside_range = container_range.intersection(range)
    container_range_size = range_size(container_range)
    range_size = range_size(range)
    return '' if range_size == 0
    offset = inside_range.begin.to_time.to_i - container_range.begin.to_time.to_i
    puts "#{name} #{container_range} #{inside_range} #{offset.to_f/range_size.to_f}"
    "top: #{(inside_range.begin.to_time.to_i - container_range.begin.to_time.to_i).to_f/(container_range_size.to_f)*100}%;";
  end
end

class HomesController < ApplicationController
  def index
    @events = File.read(Rails.root.join('timeline.txt')).split("\n").map do |line|
      data = line.split(':');
      dates = data[0].split('>')
      Event.new(
        from: parse(dates[0]),
        to: parse(dates[1] || dates[0]),
        name: data[1],
        color: %w[#F44336 #E91E63 #9C27B0 #673AB7 #3F51B5 #2196F3 #03A9F4 #00BCD4 #009688
        #4CAF50 #8BC34A #CDDC39 #FFEB3B #FFC107 #FF9800 #FF5722 #795548 #9E9E9E].sample
      )
    end
  end

  def parse(input)
    puts '>', input, Date.parse(input)
    Date.parse(input)
  end
end

def ranges_overlap?(range_a, range_b)
  range_b.begin <= range_a.end && range_a.begin <= range_b.end
end

Event = Struct.new(:from, :to, :name) do
  def overlap?(range)
    # (from..to).overlap?(range)
    ranges_overlap?((from..to), range)
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
        name: data[1]
      )
    end
  end

  def parse(input)
    puts '>', input, Date.parse(input)
    Date.parse(input)
  end
end

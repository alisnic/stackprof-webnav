require 'better_errors'

class StackProfPresenter
  attr_reader :report
  def initialize report
    @report = report
  end

  def overview_frames
    report.frames.map do |frame, info|
      call, total = info.values_at(:samples, :total_samples)
      {
        :total => total,
        :total_pct => percent(total.to_f/report.overall_samples),
        :samples => call,
        :samples_pct => percent(call.to_f/report.overall_samples),
        :method => info[:name]
      }
    end
  end

  def method_info name
    name = /#{Regexp.escape name}/ unless Regexp === name
    frames = report.frames.select do |frame, info|
      info[:name] =~ name
    end.map do |frame, info|
      file, line = info.values_at(:file, :line)

      {
        :callers => callers(frame, info),
        :callees => callees(frame, info),
        :location => "#{file}:#{line}",
        :source => BetterErrors::CodeFormatter::HTML.new(file, line).output
      }
    end
  end

  private

  def percent value
    "%2.2f%" % (value*100)
  end

  def callers frame, info
    report.data[:frames].select do |id, other|
      other[:edges] && other[:edges].include?(frame)
    end.map do |id, other|
      [other[:name], other[:edges][frame]]
    end.sort_by(&:last).reverse.map do |name, weight|
      {
        :weight =>  weight,
        :pct =>     percent(weight.to_f/info[:total_samples]),
        :method =>  name
      }
    end
  end

  def callees frame, info
    (info[:edges] || []).map do |k, weight|
      [report.data[:frames][k][:name], weight]
    end.sort_by { |k,v| -v }.map do |name, weight|
      {
        :weight =>  weight,
        :pct =>     percent(weight.to_f/(info[:total_samples]-info[:samples])),
        :method =>  name
      }
    end
  end
end
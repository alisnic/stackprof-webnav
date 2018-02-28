require 'better_errors'
require 'stringio'
require 'rexml/document'
require 'action_view'
include ActionView::Helpers::NumberHelper

module StackProf
  module Webnav
    class Presenter
      attr_reader :report
      def initialize report
        @report = report
      end

      def file_overview path
        buffer = StringIO.new
        report.print_file(path, buffer)
        data = buffer.string.split("\n").map {|l| l.split('|').first}

        {
          :lineinfo => data,
          :code => BetterErrors::CodeFormatter::HTML.new(path, 0, 9999).output
        }
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

      def listing_dumps
        Server.report_dump_listing += "/" unless Server.report_dump_listing.end_with?("/") 
        xml_data = Net::HTTP.get(URI.parse(Server.report_dump_listing))
        if xml_data
          doc = REXML::Document.new(xml_data)
          dumps = []
          doc.elements.each('ListBucketResult/Contents') do |ele|
            dumps << {
              :key => ele.elements["Key"].text, 
              :date => ele.elements["LastModified"].text,
              :size => number_with_delimiter(ele.elements["Size"].text.to_i),
              :uri => Server.report_dump_listing + ele.elements["Key"].text
            }
          end
        end
        dumps.sort_by! { |hash| hash[:date] }
        dumps.reverse!
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
            :location => file,
            :source => BetterErrors::CodeFormatter::HTML.new(file, line).output
          }
        end
      end

      private

      def percent value
        "%2.2f%%" % (value*100)
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
  end
end

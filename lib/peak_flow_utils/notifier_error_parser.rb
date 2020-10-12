class PeakFlowUtils::NotifierErrorParser
  attr_reader :backtrace, :environment, :error, :file_path, :line_number

  def initialize(backtrace:, environment:, error:)
    @backtrace = backtrace
    @environment = environment
    @error = error

    detect_file_path_and_line_number
  end

  def detect_file_path_and_line_number
    backtrace.each do |trace|
      match = trace.match(/^((.+)\.([A-z]{2,4})):(\d+)(:|$)/)
      next unless match

      file_path = match[1]
      line_number = match[4].to_i

      next if file_path.include?("/.rvm/")

      @file_path ||= file_path
      @line_number ||= line_number

      break
    end
  end

  def remote_ip
    environment&.dig("HTTP_X_FORWARDED_FOR") || environment&.dig("REMOTE_ADDR")
  end

  def user_agent
    environment&.dig("HTTP_USER_AGENT")
  end
end

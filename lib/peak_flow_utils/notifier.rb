class PeakFlowUtils::Notifier
  attr_reader :auth_token

  def self.configure(auth_token:)
    @current = PeakFlowUtils::Notifier.new(auth_token: auth_token)
  end

  def self.current
    raise "No current notifier has been set" unless @current
    @current
  end

  def self.notify(*args)
    PeakFlowUtils::Notifier.current.notify(*args)
  end

  def initialize(auth_token:)
    @auth_token = auth_token
  end

  def notify(error:, data: nil, environment: nil, parameters: nil)
    error_parser = PeakFlowUtils::NotifierErrorParser.new(
      backtrace: error.backtrace,
      environment: environment,
      error: error,
      parameters: parameters
    )

    uri = URI("https://www.peakflow.io/errors/reports")

    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true

    binding.pry

    data = {
      auth_token: auth_token,
      error: {
        backtrace: error.backtrace,
        environment: environment,
        error_class: error.class.name,
        file_path: error_parser.file_path,
        line_number: error_parser.line_number,
        message: error.message,
        parameters: parameters,
        remote_ip: error_parser.remote_ip,
        url: error_parser.url,
        user_agent: error_parser.user_agent
      }
    }

    request = Net::HTTP::Post.new(uri.path)
    request["Content-Type"] = "application/json"
    request.body = JSON.generate(data)

    response = https.request(request)
    response_data = JSON.parse(response.body)

    PeakFlowUtils::NotifierResponse.new(url: response_data.fetch("url"))
  end
end

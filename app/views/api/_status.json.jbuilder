response ||= @response

json.status do |res|
  if response.present?
    res.code response.code || Response::Code::ERROR
    res.message response.message
  else
    res.code Response::Code::ERROR
    res.message ''
  end

  res.no SecureRandom.uuid
end
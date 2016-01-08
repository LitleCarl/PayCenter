json.partial! 'api/status', response: @response

json.data do
  if @charge.present?
    json.partial! 'common/charge', charge: @charge
  end
end
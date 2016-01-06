render_json_attrs(json, charge, [:id, :live_mode, :paid, :refunded, :app_id, :channel, :order_no, :amount, :subject, :body, :time_paid, :time_expired, :transaction_no])

if charge.credential.present?
  json.credential JSON.parse(charge.credential)
else
  json.set! :credential, {}
end

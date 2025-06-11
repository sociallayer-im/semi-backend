class SigninMailer < ApplicationMailer
    default from: 'Semi <send@app.sola.day>'
    def signin
      @code = params[:code]
      @recipient = params[:recipient]
      mail(to: [@recipient], subject: 'Semi Sign-In')
    end
end

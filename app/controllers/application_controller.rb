class AppError < StandardError
end

class AuthError < AppError
end

class ApplicationController < ActionController::API
    def current_user
        return @current_user if @current_user
        header = request.headers["Authorization"]
        return unless header && header.start_with?("Bearer ")

        token = header.split(" ", 2)[1]
        return unless token

        auth_token = AuthToken.find_by(token: token)
        return unless auth_token

        @current_user = auth_token.user
    end

    def authenticate_user
        raise AuthError.new("Unauthorized") unless current_user
        current_user
    end

    rescue_from AppError do |err|
        Rails.logger.info err.message
        render json: { result: "error", message: err.message }, status: 400
    end

    rescue_from AuthError do |err|
        render json: { result: "error", message: err.message }, status: 401
    end
end

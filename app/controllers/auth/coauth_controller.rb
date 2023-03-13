# frozen_string_literal: true

require 'securerandom'
require 'addressable'

module Auth
    class AuthErrorRedirect < StandardError; end

    class CoauthController < ActionController::Base
        include UserHelper
        include CurrentAuthorityHelper


        Rails.application.config.force_ssl = Rails.env.production? && (ENV['COAUTH_NO_SSL'].nil? || ENV['COAUTH_NO_SSL'] == 'false')
        USE_SSL = Rails.application.config.force_ssl

        rescue_from AuthErrorRedirect, with: :error_redirect

        def success_path
            '/login_success.html'
        end

        def login_path
            '/login'
        end


        protected

        def redirect_continue(path)
          # checking for `.attacker.com` OR `//<external_domain>`
          # no internal paths use `//`
          check_path = path.split("?")[0]
    
          # need to check if redirect is configured in the DB
          if !check_path.start_with?("/") || check_path.include?("//")
            authority = current_authority
            uri = Addressable::URI.parse(path)
    
            path = if uri.domain == authority.domain
              "#{uri.request_uri}#{uri.fragment ? "##{uri.fragment}" : nil}"
            else
              yield
            end
          end
    
          redirect_to path
        end

        def new_session(user)
            @current_user = user
            value = {
                value: {
                    id: user.id,
                    salt: SecureRandom.hex[0..(1 + rand(31))]   # Variable length 1->32
                },
                httponly: true,
                expires: 24.hours,
                path: '/auth'   # only sent to calls at this path
            }
            value[:secure] = USE_SSL
            cookies.encrypted[:user] = value
        end

        def store_social(uid, provider)
            value = {
                value: {
                    uid: uid,
                    provider: provider,
                    salt: SecureRandom.hex[0..(1 + rand(15))]   # Variable length
                },
                httponly: true,
                expires: 10.minutes,
                path: '/auth'   # only sent to calls at this path
            }
            value[:secure] = USE_SSL
            cookies.encrypted[:social] = value
        end

        def set_continue(path)
          path ||= "/"
    
          if !path.start_with?("/") || path.include?("//")
            uri = Addressable::URI.parse(path)
            path = "#{uri.request_uri}#{uri.fragment ? "##{uri.fragment}" : nil}"
          end
    
          value = {
            value: path,
            httponly: true,
            secure: USE_SSL,
            same_site: :none,
            path: "/auth" # only sent to calls at this path
          }
          cookies.encrypted[:continue] = value
        end

        def error_redirect(exception)
            redirect_to exception.message
        end
    end
end

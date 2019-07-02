# frozen_string_literal: true, encoding: ASCII-8BIT

# To understand these tools, you need to understand how they interact with the app.
# The basic structure is as follows:
# * Site: Sydney Opera House
#   * App1: Tourism Points
#   * App2: Control Systems
#   * App3: Digital Signage
#
# Authentication processes are stored in the Authority which sits at the site level.
#  - Authority includes feature flags
#  - Where to redirect to when a user needs to authenticate
# Applications are pure OAuth2.
#  - What is their redirect URI after authentication has taken place
#  - What access scope do they need

namespace :domain do

    # Usage: rake "domain:add_authority[Name of Site,https://domain]"
    desc 'Generates an authority for the current domain'
    task :add_authority, [:site_name, :site_origin, :support_pass] => [:environment] do |task, args|
        site_name = args[:site_name]
        site_origin = args[:site_origin]  # i.e. https://domain.com
        support_pass = args[:support_pass]
        support_pass = support_pass.present? ? support_pass : 'acaTempPass'

        auth = Authority.new
        auth.name = site_name
        auth.domain = site_origin

        puts "Authority for #{site_name}: #{site_origin}"

        begin
            auth.save!

            user = User.new
            user.name = "ACA Robot (#{auth.name})"
            user.sys_admin = true
            user.authority_id = auth.id
            user.email = 'support@aca.im'
            user.password = support_pass
            user.password_confirmation = user.password
            user.save!

            puts "Authority created!\n#{site_name} = #{auth.id}\n#{user.email} : #{support_pass} = #{user.id}"
        rescue => e
            puts "Authority creation failed with:"
            if e.respond_to?(:record)
                puts e.record.errors.messages
            else
                puts "#{e.message}\n#{e.backtrace.join("\n")}"
            end
        end
    end

    # Usage: rake "domain:add_app[Name of App,https://domain/path]"
    desc 'Generates an application ID for an interface'
    task :add_app, [:app_name, :app_base, :scope] => [:environment] do |task, args|
        app_name = args[:app_name]
        app_base = args[:app_base]
        scope = args[:scope]

        redirect_uri = "#{app_base}/oauth-resp.html"
        app_id = Digest::MD5.hexdigest redirect_uri

        puts "Building Application #{app_name}: #{redirect_uri}"

        app = Doorkeeper::Application.new
        app.name = app_name
        app.secret = SecureRandom.hex(48)
        app.redirect_uri = redirect_uri
        app.id = app_id
        app.uid = app_id
        app.scopes = scope.present? ? scope : 'public'
        app.skip_authorization = true

        begin
            app.save!
            puts "App '#{app_name}' added with ID #{app.id}"
        rescue => e
            begin
                puts "App creation failed with: #{e.message}"
                puts app.errors.messages
            rescue
                puts "#{e.message}\n#{e.backtrace.join("\n")}"
            end
        end
    end

end

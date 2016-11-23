# frozen_string_literal: true

namespace :migrate do

    desc 'Migrate emails to isolate by authority'

    task :emails => :environment do
        bucket = User.bucket

        User.all.each do |user|
            bucket.delete("useremail-#{user.email}", {quiet: true})
            bucket.delete("useremail-#{User.process_email(user.authority_id, user.email)}", {quiet: true})
            #user.authority_id = 'sgrp_3-10' # Might be worth adding these lines with the appropriate authority
            #user.save!
            bucket.set("useremail-#{User.process_email(user.authority_id, user.email)}", user.id)
        end
    end

end

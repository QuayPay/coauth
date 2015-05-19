namespace :migrate do

    desc 'Migrate emails to isolate by authority'

    task :emails => :environment do
        bucket = User.bucket

        User.all.each do |user|
            bucket.delete("useremail-#{self.email}", {quiet: true})
            bucket.set("useremail-#{User.process_email(user.authority_id, user.email)}", user.id)
        end
    end

end

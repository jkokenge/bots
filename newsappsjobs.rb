require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
Bitly.use_api_version_3

class Twitterbot 
  attr_accessor :jobs, :twitter_config, :gdrive_session, :job_worksheet, :bitly
 
    def initialize
        @twitter_config = Psych.load_file('config.yml')
        @gdrive_session = GoogleDrive.login(@twitter_config['g_drive_login'], @twitter_config['g_drive_app_pass'])
        @job_worksheet = @gdrive_session.spreadsheet_by_key(@twitter_config['jobs_ws_key']).worksheets[0]
        @bitly = Bitly.new(@twitter_config['bitly_user_name'], @twitter_config['bitly_api_key'])
        @jobs = []

        Twitter.configure do |config|
            config.consumer_key = @twitter_config['consumer_key']
            config.consumer_secret = @twitter_config['consumer_secret']
            config.oauth_token = @twitter_config['oauth_token']
            config.oauth_token_secret = @twitter_config['oauth_token_secret']
        end
    end

    def shorten_link(link)
        begin
            shorter_link = @bitly.shorten(link).short_url
        rescue => e 
            e
        end
    end
    
    def short_time
      Time.new.to_s.match(/\d\d\-\d\d\s\d\d:\d\d/).to_s
    end


    def make_jobs
        @job_worksheet.rows.each do |row|
            if row[2].match(/\d\/\d+\/2013/) 
                unless shorten_link(row[0]).class.to_s == 'BitlyError' 
                    @jobs << "#{row[1].strip.chomp}, #{row[5]}: #{row[4]} #{shorten_link(row[0])} #newapps #ddj #{short_time}"
                else
                    @jobs << "#{row[1].strip.chomp}, #{row[5]}: #{row[4]} #{row[0]} #newapps #ddj #{short_time}"
                end#unless
            end#if
        end

    puts @jobs.sample
    
    end#make_jobs


end#Twitterbot class

bot = Twitterbot.new 
#Twitter.update(bot.make_jobs)
 bot.make_jobs

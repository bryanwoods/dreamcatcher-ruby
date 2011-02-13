require 'rubygems'
require 'sinatra'
require 'haml'
require 'pony'
require 'mongo_mapper'

before do
  set :environment, :production

  if ENV['MONGOHQ_URL']
    MongoMapper.config = {:environment => {'uri' => ENV['MONGOHQ_URL']}}
  else
    MongoMapper.config = {:environment => {'uri' => 'mongodb://localhost/error-catcher'}}
  end

  MongoMapper.database = 'reports'
  MongoMapper.connect(:environment)

  @email_sender    = "bryanwoods4e@gmail.com"
  @email_recipient = @email_sender
end

class Report
  include MongoMapper::Document

  key :message, String
  key :location, String
  key :browser_name, String
  key :browser_version, String
  key :line_number, String
end

get '/' do
  haml :index
end

get '/errors' do; end

post '/errors' do
  @error = params[:error]

  report = Report.create({
    :message         => @error[:message],
    :location        => @error[:location],
    :browser_name    => @error[:browser_name],
    :browser_version => @error[:browser_version],
    :line_number     => @error[:line_number]
  })

  if report.save
    Pony.mail(
      :to        => @email_recipient,
      :from      => @email_sender,
      :subject   => "JavaScript Error: #{report[:message]} (on line #{report[:line_number]})",
      :html_body => haml(:email),
      :port      => '587',
      :via       => :smtp,
      :via_options => { 
        :address              => 'smtp.sendgrid.net', 
        :port                 => '587', 
        :enable_starttls_auto => true, 
        :user_name            => ENV['SENDGRID_USERNAME'], 
        :password             => ENV['SENDGRID_PASSWORD'], 
        :authentication       => :plain, 
        :domain               => ENV['SENDGRID_DOMAIN']
      }
    )
  end
end

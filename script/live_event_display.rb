# Live Event Display
# 
# This is just a web display of current events during the
# go-live celebration.
#
# The content of the file /var/wingolfsplattform/tmp/live_event.txt
# is displayed.
#
# http://wingolfsplattform.org:
#
# Launch this tool: 
# 
#     ruby script/live_event_display.rb
#     nohup ruby script/live_event_display.rb > /dev/null &
#

require 'sinatra'

set :environment, :production
set :port, 4568

# http auth
# http://www.sinatrarb.com/faq.html#auth
#
helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    correct_username = "aki"
    correct_password = "aki"
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == [correct_username, correct_password]
  end
end

get '/' do
  protected!
  
  html = "
  <html><head>
    <title>Live Event Display</title>
    <script type='text/javascript' src='http://code.jquery.com/jquery-latest.min.js'></script>
    <script type='text/javascript' src='http://cdnjs.cloudflare.com/ajax/libs/gsap/latest/TweenMax.min.js'></script>
    <script type='text/javascript' src='http://www.cooltextjs.com/js/angular.min.js'></script>
    <script type='text/javascript' src='https://wingolfsplattform.org/js/vendor/cooltext/cooltext.animations.js'></script>      
    <script type='text/javascript' src='https://wingolfsplattform.org/js/vendor/cooltext/cooltext.min.js'></script>      
    <script language='javascript'>
      setTimeout(function(){
         window.location.reload(1);
      }, 60000);
    </script>
    <style type='text/css'>
      body {
        background-color: #111;
        background-image: url('https://winglfsplattform.org/images/presentation-bg.jpg');
        background-size: auto 100%;
      }
      #wrapper {
        display: table;
        width: 100%;
        height: 100%;
        text-align: center;
      }
      #live_event_text {
        display: table-cell;
        vertical-align: middle;
      
        color: #fff;
        font-size: 60pt;
        font-family: sans-serif;
      }
    </style>
  </head><body>
    <div id='wrapper'>
      <span id='live_event_text'> <!--ct-config='cycle' ct-sequence='cool56|cool120|cool298'-->
        {live_event_text}
      </span>
    </div>
  
  </body></html>
  "
  
  html.gsub('{live_event_text}', event_text_file_content)
  
end

def event_text_file_content
  format_string File.read File.expand_path '../../tmp/live_event.txt', __FILE__
end

def format_string(str)
  str.gsub("\n", "<br>")
end


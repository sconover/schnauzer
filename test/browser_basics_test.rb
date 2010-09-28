require "./test/test_helper"

require "schnauzer"

regarding Schnauzer::Browser do
  before do
    @browser = Schnauzer::Browser.new
  end
  
  test "loads and displays html" do
    @browser.load_html(
      (<<-HTML)
      <html>
        <body>
        	<i>hello world</i>
        </body>
      </html>
      HTML
    )

    assert{ @browser.js("document.body.innerHTML").include?("<i>hello world</i>") }
  end
  
  test "uses base url provided to make absolute urls" do
    @browser.load_html(%{
      <html>
        <body>
        	<a id="mylink" href="/mypage.html">linky</a>
        </body>
      </html>}, 
      "http://bar")
    
    
    assert{ @browser.js("document.getElementById('mylink').href") == "http://bar/mypage.html" }
  end
  
  test "executes javascript" do
    @browser.load_html(
      (<<-HTML)
      <html>
        <body>
        	hello <div id="the_spot"></div>
        	
        	<script type="text/javascript">
          	document.getElementById('the_spot').innerHTML='world'
        	</script>
        </body>
      </html>
      HTML
    )
    
    assert{ @browser.js("document.body.innerHTML").include?(%{hello <div id="the_spot">world</div>}) }
  end
  
  test "load from url" do
    @browser.load_url("file://#{File.expand_path("test/little_page.html")}")
    assert{ @browser.js("document.body.innerHTML").include?(%{hello <div id="foo">world</div>}) }
  end
  
  test "performance" do
    n = 100
    time = 
      Benchmark.realtime {
        n.times do
          @browser.load_html(
            (<<-HTML)
            <html>
              <body>
              	hello <div id="the_spot"></div>
        	
              	<script type="text/javascript">
                	document.getElementById('the_spot').innerHTML='world'
              	</script>
              </body>
            </html>
            HTML
          )
        end
      }
    puts "basic html load: #{n} requests in #{time}s  #{(time*1000)/n}ms/r  #{n.to_f/time.to_f}r/s"
  end
end
require 'osx/cocoa'

OSX.require_framework 'WebKit'

module Schnauzer
  class Browser
    def initialize(options={})
      defaults = {
        :width => 1024, 
        :height => 768
      }
      options = options.merge(defaults)
      
      
      OSX.NSApplicationLoad
    
      @window = OSX::NSWindow.alloc.initWithContentRect_styleMask_backing_defer(
        OSX::NSRect.new(0, 0, options[:width], options[:height]), 
        OSX::NSBorderlessWindowMask, 
        OSX::NSBackingStoreBuffered, 
        false
      )
      @view = OSX::WebView.alloc.initWithFrame(OSX::NSRect.new(0, 0, options[:width], options[:height]))
    
      @view.setFrameLoadDelegate(WebFrameLoadDelegate.alloc.init)
      # @view.mainFrame.frameView.setAllowsScrolling(false)
    
      # Replace the window's content @view with the web @view
      @window.setContentView(@view)
      @view.release
    end
  
    def load_html(html, base_url="http://localhost")
      osx_base_url = OSX::NSURL.alloc.initWithString(base_url)
      @view.mainFrame.loadHTMLString_baseURL(html, osx_base_url)
      _run_load
    end
  
    def load_url(url)
      @view.mainFrame.loadRequest(
        OSX::NSURLRequest.requestWithURL(
          OSX::NSURL.alloc.initWithString(url)
        )
      )
      _run_load
    end
  
    def _run_load
      OSX.CFRunLoopRun #this blocks until the frame loads (see LoadDelegate)

      # @view.setNeedsDisplay(true)
      # @view.displayIfNeeded
      # @view.lockFocus
      # @view.unlockFocus
    end
  
    def js(str)
      result = @view.mainFrameDocument.evaluateWebScript(str)
      result = result.is_a?(OSX::NSCFString) ? result.to_s : result    
      result
    end
  end
  
  
  class WebFrameLoadDelegate < OSX::NSObject

    def webView_didFinishLoadForFrame(sender, frame)
      OSX.CFRunLoopStop(OSX.CFRunLoopGetCurrent)
    end

    def webView_didFailLoadWithError_forFrame(webview, load_error, frame)
      OSX.CFRunLoopStop(OSX.CFRunLoopGetCurrent)
    end

    def webView_didFailProvisionalLoadWithError_forFrame(webview, load_error, frame)
      OSX.CFRunLoopStop(OSX.CFRunLoopGetCurrent)
    end
  
    def webView_didStartProvisionalLoadForFrame(v, frame)
    end
  
    def webView_didCommitLoadForFrame(v, frame)
    end
  
    def webView_willCloseFrame(v, frame)
    end
  
    def webView_didChangeLocationWithinPageForFrame(v, frame)
    end
  
    def webView_didReceiveTitle_forFrame(v, title, frame)
    end
  
    def webView_didReceiveIcon_forFrame(v, icon, frame)
    end
  
    def webView_didCancelClientRedirectForFrame(v, frame)
    end
  
    def webView_willPerformClientRedirectToURL_delay_fireDate_forFrame(v, url, delay, fire_date, frame)
    end
  
    def webView_didReceiveServerRedirectForProvisionalLoadForFrame(v, frame)
    end
  
    def webView_didClearWindowObject_forFrame(v, window, frame)
    end
  end
  
  class WebResourceLoadDelegate < OSX::NSObject
  
    def webView_resource_willSendRequest_redirectResponse_fromDataSource(v, resource, request, response, source)
      request_headers = request.allHTTPHeaderFields.to_hash
      if request_headers.values.collect{|v|v.to_s}.include?("XMLHttpRequest")
        @unresolved_ajax_request = true
      end
    
      request
    end
  
    def webView_resource_didFinishLoadingFromDataSource(v, resource, source)
    end
  
    def webView_resource_didReceiveResponse_fromDataSource(v, resource, response, source)
      # puts "webView_resource_didReceiveResponse_fromDataSource  #{response.URL.to_s}"
    end
  
    def webView_resource_didReceiveContentLength_fromDataSource(v, resource, length, source)
      # puts "webView_resource_didReceiveContentLength_fromDataSource  #{length}"
    end
  
    def webView_resource_didFailLoadingWithError_fromDataSource(v, resource, error, source)
      # p 6
    end
  
    def webView_plugInFailedWithError_dataSource(v, error, source)
      # p 7
    end
  
    def webView_resource_didReceiveAuthenticationChallenge_fromDataSource(v, resource, challenge, source)
      # p 8
    end
  
    def webView_resource_didCancelAuthenticationChallenge_fromDataSource(v, resource, challenge, source)
      # p 9
    end
  end
end
require 'httparty'
class Ardeli
  include HTTParty

  def initialize(token, dev = false)
    @uri = api_uri(token, dev)
  end
    
  def calculate(options = {})
    lat       = options[:lat]
    lng       = options[:lng]
    weight    = options[:weight]
    service   = options[:service]
    uri = "#{@uri}/#{lat}/#{lng}/#{weight}"
    uri = "#{uri}/#{service}" if service
    @response = Response.new self.class.get(uri)
  end
    
  def info(options = {})
    id  = options[:id] rescue options
    uri = "#{@uri}/#{id}"
    @response = self.class.get(uri)
  end
  
  def response
    @response
  end
  
  private
  class Response
    def initialize(response)
      @response = response
    end
    
    def debug
      @response
    end
    
    def id
      @response["id"] rescue nil
    end
    
    def distance
      @response["distance"].to_f rescue nil
    end
    
    def weight
      @response["weight"].to_f rescue nil
    end
    
    def when
      @response["when"].to_datetime rescue nil
    end
    
    def services
      _result = []
      begin
        @response["results"].values.each do |service|
          _result << Service.new(service)
        end
      rescue
      end
      return _result
    end
    
    def service
      Service.new({
        "provider"    => @response["provider"],
        "service"     => @response["service"],
        "description" => @response["description"],
        "cost"        => @response["cost"]
      })
    end
    
    private
    class Service
      def initialize(result)
        @result = result
      end
      
      def provider
        @result["provider"] rescue nil
      end
      
      def name
        @result["service"] rescue nil
      end
      
      def description
        @result["description"] rescue nil
      end
      
      def cost
        Cost.new(@result["cost"]) rescue nil
      end
      
      private
      class Cost
        def initialize(cost)
          @cost = cost
        end
        
        def actual
          @cost["actual"].to_f rescue 0.0
        end
        
        def saved
          @cost["saved"].to_f rescue 0.0
        end
        
        def extra
          Extra.new(@cost["extra"])
        end
        
        def total
          extra.cost + saved
        end
        
        private
        class Extra
          def initialize(extra)
            @extra = extra
          end
          
          def kg
            @extra["kg"].to_f rescue 0.0
          end
          
          def cost
            @extra["cost"].to_f rescue 0.0
          end
        end
      end
    end
  end
  
  def api_uri(token, dev = false)
    if dev
      "http://localhost:3050/api/#{token}"
    else
      "http://ardeli.com.ar/api/#{token}"
    end
  end
end
#
# Middleware functionality
#
module Sinatra
 module YSD 
   module CustomersManagement
    
     def self.registered(app)
      
        #
        # Customers management
        #
        app.get '/admin/customers/customers/?*', :allowed_usergroups => ['booking_manager','staff'] do

          # TODO : Review because it's a booking plugin configuration
          @product_family = ::Yito::Model::Booking::ProductFamily.get(SystemConfiguration::Variable.get_value('booking.item_family'))
          
          locals = {:customers => 20}
          load_em_page :customers_management,
                       :customers, false, :locals => locals

        end


     end
    end #CustomersManagement 
 end #YSD
end #Sinatra

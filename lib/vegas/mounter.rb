module Vegas
  class MountError < RuntimeError; end
  
  class Mounter
    RESERVED_MOUNTS = ['/', '/vegas']
    
    class << self
                  
      def mounts
        @@mounts ||= {}
      end
      
      def mount!(name, app_instance)
        name = mountable_name(name)
        if (mounts.keys + RESERVED_MOUNTS).include?(name)
          raise Vegas::MountError, "Can not mount #{name}: Already in use"
        end
        mounts[name] = app_instance
      end
      
      def clear_mounts!
        @@mounts = {}
      end
      
      private
      
      def mountable_name(name)
        name =~ /^\// ? name : '/' + name
      end
      
    end
    
  end
end
class KeyValue
    attr_reader :key, :value
    
    def initialize(keyName, value, encrypted, overridden, default)
        @key = keyName
        @value = value
        @encrypted = encrypted
        @overridden = overridden
        @default = default
    end
    
    def encrypted?
      @encrypted
    end
    
    def default?
      @default
    end
    
    def overridden?
      @overridden
    end
    
end
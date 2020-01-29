module HashRefinements
  refine Hash do
    def symbolize_keys
      self.inject({}) do |acc, (key, value)|
        acc[key.to_sym] = value
        acc
      end
    end

    def except(keys)
      self.inject({}) do |acc, (key, _)|
        unless keys.include?(k.to_sym) || keys.include?(k.to_s)
          acc[key] = hash[k]
        end

        acc
      end
    end
  end
end

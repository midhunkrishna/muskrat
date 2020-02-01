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
        unless keys.include?(key.to_sym) || keys.include?(key.to_s)
          acc[key] = self[key]
        end
        acc
      end
    end
  end
end

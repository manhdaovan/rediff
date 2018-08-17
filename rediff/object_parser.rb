module Rediff
  #
  # Parsing object to json viewing
  #
  # Input:
  # {a: "this is string", b: 2, c: {d: nil, g: false, k: true, e: [{f: "this is another string"}]}}
  #
  # Output:
  # {
  #   "a": "this is string",
  #   "b": 2,
  #   "c": {
  #     "d": nil,
  #     "g": false,
  #     "k": true,
  #     "e": [
  #          {
  #            "f": "this is another string"
  #        }
  #     ]
  #   }
  # }
  class ObjectParser
    def self.parse_object(obj, spaces_num)
      if obj.is_a?(Hash)
        parse_hash(obj, spaces_num)
      elsif obj.is_a?(Array)
        parse_array(obj, spaces_num)
      elsif obj.is_a?(Integer)
        parse_int(obj)
      elsif obj.is_a?(String)
        parse_string(obj)
      elsif obj.is_a?(NilClass)
        parse_nil
      elsif obj.is_a?(FalseClass)
        parse_false
      elsif obj.is_a?(TrueClass)
        parse_true
      else
        obj.to_s
      end
    end

    def self.parse_hash(obj, spaces_num)
      str = "\n" + ' ' * spaces_num + "{\n"
      str += obj.keys.map do |k|
        sub_str = ''
        sub_str += ' ' * (spaces_num + 1) + parse_object(k, spaces_num) + ': '
        sub_str += parse_object(obj[k], spaces_num + 1)
        sub_str
      end.join(",\n")

      str += ' ' * spaces_num + "}\n"
      str
    end

    def self.parse_array(obj, spaces_num)
      str = '['

      str += obj.map do |o|
        parse_object(o, spaces_num + 1)
      end.join(",\n")

      str += ' ' * spaces_num + "]\n"
      str
    end

    def self.parse_int(obj)
      obj.to_s
    end

    def self.parse_string(obj)
      '"' + obj + '"'
    end

    def self.parse_nil
      'null'
    end

    def self.parse_false
      'false'
    end

    def self.parse_true
      'true'
    end
  end
end

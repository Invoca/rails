class AbstractMethodCalled < TypeError; end

class Module
  def abstract_method(*method_names)
    method_names.each do |method_name|
      define_method(method_name) do
        raise AbstractMethodCalled, "Must implement method #{method_name}"
      end
    end
  end
end
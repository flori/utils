module Utils::IRB::Shell
  # Base class for wrapping objects with descriptive metadata.
  #
  # This class provides a foundation for creating wrapper objects that
  # associate descriptive information with underlying objects. It handles
  # name conversion and provides common methods for accessing and comparing
  # wrapped objects.
  class WrapperBase
    include Comparable

    # The initialize method sets up the instance name by converting the
    # input to a string representation.
    #
    # This method handles different input types by converting them to a
    # string, prioritizing to_str over to_sym and falling back to to_s if
    # neither is available.
    #
    # @param name [ Object ] the input name to be converted to a string
    def initialize(name)
      @name =
        case
        when name.respond_to?(:to_str)
          name.to_str
        when name.respond_to?(:to_sym)
          name.to_sym.to_s
        else
          name.to_s
        end
    end

    # The name reader method returns the value of the name instance
    # variable.
    #
    # @return [ String] the value stored in the name instance variable
    attr_reader :name

    # The description reader method provides access to the description
    # attribute.
    #
    # @return [ String, nil ] the description value or nil if not set
    attr_reader :description

    alias to_str description

    alias inspect description

    alias to_s description

    # The == method assigns a new name value to the instance variable.
    #
    # @param name [ Object ] the name value to be assigned
    #
    # @return [ Object ] returns the assigned name value
    def ==(name)
      @name = name
    end

    alias eql? ==

    # The hash method returns the hash value of the name attribute.
    #
    # @return [ Integer ] the hash value used for object identification
    def hash
      @name.hash
    end

    # The <=> method compares the names of two objects for sorting purposes.
    #
    # @param other [ Object ] the other object to compare against
    #
    # @return [ Integer ] -1 if this object's name is less than the other's,
    #         0 if they are equal, or 1 if this object's name is greater than the other's
    def <=>(other)
      @name <=> other.name
    end
  end

  # A wrapper class for Ruby constant objects that provides enhanced
  # introspection and display capabilities.
  #
  # This class extends WrapperBase to create specialized wrappers for Ruby
  # constant objects, offering detailed information about constants
  # including their names and associated classes. It facilitates
  # interactive exploration of Ruby constants in environments like IRB by
  # providing structured access to constant metadata and enabling sorting
  # and comparison operations based on constant descriptions.
  class ConstantWrapper < WrapperBase
    # The initialize method sets up a new instance with the provided object
    # and name.
    #
    # This method configures the instance by storing a reference to the
    # object's class and creating a description string that combines the
    # name with the class name.
    #
    # @param obj [ Object ] the object whose class will be referenced
    # @param name [ String ] the name to be used in the description
    #
    # @return [ Utils::Patterns::Pattern ] a new pattern instance configured with the provided arguments
    def initialize(obj, name)
      super(name)
      @klass = obj.class
      @description = "#@name:#@klass"
    end

    # The klass reader method provides access to the class value stored in the instance.
    #
    # @return [ Object ] the class value
    attr_reader :klass
  end


  # A wrapper class for Ruby method objects that provides enhanced
  # introspection and display capabilities.
  #
  # This class extends WrapperBase to create specialized wrappers for Ruby
  # method objects, offering detailed information about methods including
  # their source location, arity, and owner. It facilitates interactive
  # exploration of Ruby methods in environments like IRB by providing
  # structured access to method metadata and enabling sorting and
  # comparison operations based on method descriptions.
  class MethodWrapper < WrapperBase
    # The initialize method sets up a new instance with the specified
    # object, method name, and module flag.
    #
    # This method creates and configures a new instance by storing the
    # method object and its description, handling both instance methods and
    # regular methods based on the module flag parameter.
    #
    # @param obj [ Object ] the object from which to retrieve the method
    # @param name [ String ] the name of the method to retrieve
    # @param modul [ TrueClass, FalseClass ] flag indicating whether to retrieve an instance method
    def initialize(obj, name, modul)
      super(name)
      @wrapped_method = modul ? obj.instance_method(name) : obj.method(name)
      @description = @wrapped_method.description(style: :namespace)
    end

    # The method reader returns the method object associated with the
    # instance.
    attr_reader :wrapped_method

    # The owner method retrieves the owner of the method object.
    #
    # This method checks if the wrapped method object responds to the owner
    # message and returns the owner if available, otherwise it returns nil.
    #
    # @return [ Object, nil ] the owner of the method or nil if not applicable
    def owner
      @wrapped_method.respond_to?(:owner) ? @wrapped_method.owner : nil
    end

    # The arity method returns the number of parameters expected by the method.
    #
    # @return [ Integer ] the number of required parameters for the method
    def arity
      @wrapped_method.arity
    end

    # The source_location method retrieves the file path and line number
    # where the method is defined.
    #
    # This method accesses the underlying source location information for
    # the method object, returning an array that contains the filename and
    # line number of the method's definition.
    #
    # @return [ Array<String, Integer> ] an array containing the filename and line number
    #         where the method is defined, or nil if the location cannot be determined
    def source_location
      @wrapped_method.source_location
    end

    # The <=> method compares the descriptions of two objects for ordering
    # purposes.
    #
    # @param other [ Object ] the other object to compare against
    #
    # @return [ Integer ] -1 if this object's description is less than the other's,
    #         0 if they are equal, or 1 if this object's description is greater than the other's
    def <=>(other)
      @description <=> other.description
    end
  end
end

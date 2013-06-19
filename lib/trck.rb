require 'storage'
require 'organization'


class Trck
  class << self
    def setup input
      @storage = Storage.load
      @storage.setup(input)
    end

    def org *args
      args.flatten!
      return show_organizations if args.none?

      return mark_organization_active(args) if args.one?

      return add_organization(args) if args[0] == 'add'

      if args[0] == 'remove'
        return destroy_organization(args) if get_arg(args, '-R')
        return delete_organization(args)
      end
    end

    def mark_organization_active args
      o = Organization.find_by_name(args.first)
      return "Organization #{args.first} was not found" unless o
      (o.mark_active) ? "Organization #{args.first} was marked as default" : "An error occurred"
    end

    def show_organizations
      Organization.all.collect{|x|
        x.active? ? "=> #{x.name}" : "#{x.name}"
      }.join("\n")
    end

    def add_organization args
      o = Organization.new(args[1])
      (o.save) ? "Organization #{args[1]} added" : o.errors.first
    end

    def delete_organization name

    end

    def destroy_organization args
      o = Organization.find_by_name(args[1])
      return "Organization #{args[1]} was not found" unless o

      res = prompt("Are you sure you want to delete organization #{args[1]} with projects and tasks? (yes/no): ").delete("\n")
      if res == 'yes'
        return "Organization #{args[1]} with projects and tasks removed" if o.destroy
      end
    end

    def prompt p
      print p
      $stdin.gets
    end

    def self.sync

    end

    def get_arg args, arg
      if args.index('-R')
        args.delete_at(args.index('-R'))
        args
      end
    end

  end
end
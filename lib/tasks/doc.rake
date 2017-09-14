# Rails loads its task after ours, preventing us from clearing them.
# But we need to overwrite them, so we require them manually in order
# to clear them.
# This require was spotted in railties-4.0.4/lib/rails/application.rb:245
require 'rails/tasks'

# Clearing Rails docs tasks
%w(
  doc
  doc/app
  doc/app/index.html
  doc:app
  doc:clobber
  doc:clobber_app
  doc:clobber_rails
  doc:guides
  doc:rails
  doc:reapp
  doc:rerails
).each do |task|
  Rake::Task[task].clear
end

# Adapted from railties-4.0.4/lib/rails/tasks/documentation.rake
begin
  require 'rdoc/task'
rescue LoadError
  # Rubinius installs RDoc as a gem, and for this interpreter "rdoc/task" is
  # available only if the application bundle includes "rdoc" (normally as a
  # dependency of the "sdoc" gem.)
  #
  # If RDoc is not available it is fine that we do not generate the tasks that
  # depend on it. Just be robust to this gotcha and go on.
else
  namespace :doc do
    # Monkey-patch to remove redoc'ing and clobber descriptions to cut down on rake -T noise
    class RDocTaskWithoutDescriptions < RDoc::Task
      include ::Rake::DSL

      def define
        task rdoc_task_name

        task rerdoc_task_name => [clobber_task_name, rdoc_task_name]

        task clobber_task_name do
          rm_r rdoc_dir rescue nil
        end

        task :clobber => [clobber_task_name]

        directory @rdoc_dir
        task rdoc_task_name => [rdoc_target]
        file rdoc_target => @rdoc_files + [Rake.application.rakefile] do
          rm_r @rdoc_dir rescue nil
          @before_running_rdoc.call if @before_running_rdoc
          args = option_list + @rdoc_files
          if @external
            argstring = args.join(' ')
            sh %{ruby -Ivendor vendor/rd #{argstring}}
          else
            require 'rdoc/rdoc'
            RDoc::RDoc.new.document(args)
          end
        end
        self
      end
    end

    RDocTaskWithoutDescriptions.new("app") { |rdoc|
      require 'sdoc'

      rdoc.rdoc_dir = 'doc/app'
      rdoc.template = ENV['template'] if ENV['template']
      rdoc.title    = ENV['title'] || "DESY - Digital Educational SYstem application documentation"
      rdoc.main     = 'doc/README.md'
      rdoc.markup   = 'markdown'

      rdoc.options << '--fmt' << 'sdoc'
      rdoc.options << '--all'
      rdoc.options << '--line-numbers'
      rdoc.options << '--charset' << 'utf-8'
      rdoc.rdoc_files.include('doc/README.md')
      rdoc.rdoc_files.include('app/**/*.rb')
      rdoc.rdoc_files.include('lib/**/*.rb')
    }
    Rake::Task['doc:app'].comment = "Generate docs for the app (options: TEMPLATE=/rdoc-template.rb, TITLE=\"Custom Title\")"
  end
end

namespace :doc do
  desc "Build JS documentation"
  task :js do
    src_dir = 'app/assets/javascripts/'
    doc_dir = 'doc/js'

    command = "cd #{Rails.root.to_s.shellescape} && yuidoc -c config/yuidoc.json -o #{doc_dir.shellescape} #{src_dir.shellescape}"

    puts "Running `#{command}` ..."
    `#{command}`
  end
end

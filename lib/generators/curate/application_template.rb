def with_git(message)
  yield if block_given?
  if ! options.fetch('skip_git', false)
    git :init
    git add: '.'
    git commit: "-a -m '#{message}'"
  end
end
def yes_with_banner?(message, banner = "*" * 80)
  yes?("\n#{banner}\n\n#{message}\n#{banner}\nType y(es) to confirm:")
end

with_git("Initial commit")

with_git("Adding curate gem") do
  gem 'curate', "~> 0.4.1"
end

DOI_QUESTION =
<<-QUESTION_TO_ASK
Would you like to allow remote minting of Digital Object Identifiers (DOI)s?

More information at http://simple.wikipedia.org/wiki/Doi
QUESTION_TO_ASK

with_doi_answer = yes_with_banner?(DOI_QUESTION)

command = [:curate, "--with-doi=#{with_doi_answer}"]

with_git("Install curate gem with#{with_doi_answer ? '' : 'out' } DOI support\n\nWith generator: #{command.join(' ')}") do
  generate(*command)
end

JETTY_QUESTION =
<<-QUESTION_TO_ASK
Would you like to use jettywrapper for your SOLR and Fedora?

More information at https://github.com/projecthydra/jettywrapper/
QUESTION_TO_ASK

if yes_with_banner?(JETTY_QUESTION)
  with_git("Configuring to ignore jetty dir") do
    append_file '.gitignore', "\njetty/\n"
  end

  with_git("Installing jettywrapper") do
    gem 'jettywrapper', group: [:development, :test]
    run 'bundle install'
  end

  with_git("Downloading jettywrapper") do
    if yes_with_banner?("Would you like to download jetty now?\n\nThis will take quite awhile based on download speeds.")
      rake "jetty:download"
      rake "jetty:config"
    end
  end
end

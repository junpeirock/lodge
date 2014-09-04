RSpec.shared_examples "having markdownable" do |attr|
  setter = "#{attr}="
  attr_html = "#{attr}_html"

  subject (:model) { described_class.new }

  describe attr_html do

      where(:md, :html) do
        [
          ['#title', '<h1 id="title">title</h1>']
        ]
      end
  
      with_them do
        before { model.send setter, md }
        its(attr_html) { should match html }
      end
  end

end

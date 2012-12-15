cfndsl
======
Although AWS Cloudformation templates are incredibly powerful, they are also difficult to write and maintain.

This gem provides a simple DSL that allows you to write equivalent templates in a more friendly language 
and generate the correct json templates by running ruby. 

In the samples directory, the file "autoscale.template" is one of the sample templates provided by AWS. The
file "autoscale.rb" is its analog in the ruby DSL. 

usage: cfndsl template.rb

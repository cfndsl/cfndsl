# frozen_string_literal: true

require 'spec_helper'

describe CfnDsl::CloudFormationTemplate do
  it_behaves_like 'an orchestration template'

  context '#validate' do
    it 'returns self if the template is empty' do
      # TODO: Strictly Cloudformation requires at least one resource, but this is not validated yet.
      expect(subject.validate).to equal(subject)
    end

    context 'resources' do
      it 'returns self if there are valid Refs to parameters' do
        subject.Parameter('TestParameter').Type('String')
        r = subject.Resource(:TestResource)
        r.Type('Custom-TestType')
        r.Property(:AProperty, r.Ref(:TestParameter))
        expect(subject.validate).to equal(subject)
      end

      it 'returns self if there are valid Refs to other resources' do
        tr = subject.Resource(:TestResource)
        tr.Type('Custom-TestType')
        tr.Property(:AProperty, tr.Ref(:TestResource2))

        t2 = subject.Resource('TestResource2')
        t2.Type('Custom-TestType')
        expect(subject.validate).to equal(subject)
      end

      it 'returns self if there are valid Fn::GetAtt references to other resources' do
        tr = subject.Resource(:TestResource)
        tr.Type('Custom-TestType')
        tr.Property(:AProperty, tr.FnGetAtt(:TestResource2, :AnAttribute))

        t2 = subject.Resource('TestResource2')
        t2.Type('Custom-TestType')
        expect(subject.validate).to equal(subject)
      end

      it 'returns self if there are valid DependsOn to other resources' do
        tr = subject.Resource(:TestResource)
        tr.Type('Custom-TestType')
        tr.DependsOn(:TestResource2)

        t2 = subject.Resource('TestResource2')
        t2.Type('Custom-TestType')
        expect(subject.validate).to equal(subject)
      end

      it 'raises CfnDsl::Error if references a non existent condition' do
        tr = subject.Resource(:TestResource)
        tr.Condition('NoCondition')
        expect { subject.validate }.to raise_error(CfnDsl::Error, /TestResource.*NoCondition/)
      end

      it 'raises CfnDsl::Error if there are invalid Refs' do
        tr = subject.Resource(:TestResource)
        tr.Type('Custom-TestType')
        tr.Property(:AProperty, tr.Ref(:TestResource2))
        expect { subject.validate }.to raise_error(CfnDsl::Error, %r{^Invalid Reference:.*TestResource.*TestResource2})
      end

      it 'raises CfnDsl::Error if there are invalid Fn::GetAtt references' do
        tr = subject.Resource(:TestResource)
        tr.Type('Custom-TestType')
        tr.Property(:AProperty, tr.FnGetAtt(:TestResource2, :AnAttribute))
        expect { subject.validate }.to raise_error(CfnDsl::Error, %r{^Invalid Reference:.*TestResource.*TestResource2})
      end

      it 'raises CfnDsl::Error if there are invalid Fn::Sub attribute references' do
        tr = subject.Resource(:TestResource)
        tr.Type('Custom-TestType')
        tr.Property(:AProperty, tr.FnBase64(tr.FnSub('${TestResource2.AnAttribute}')))
        expect { subject.validate }.to raise_error(CfnDsl::Error, %r{^Invalid Reference:.*TestResource.*TestResource2})
      end

      it 'raises CfnDsl::Error if there are invalid Fn::Sub references' do
        tr = subject.Resource(:TestResource)
        tr.Type('Custom-TestType')
        tr.Property(:AProperty, tr.FnBase64(tr.FnSub('${TestResource2}')))
        expect { subject.validate }.to raise_error(CfnDsl::Error, %r{^Invalid Reference:.*TestResource.*TestResource2})
      end

      it 'raises CfnDsl::Error if there are invalid DependsOn' do
        tr = subject.Resource(:TestResource)
        tr.Type('Custom-TestType')
        tr.DependsOn(['TestResource2'])
        expect { subject.validate }.to raise_error(CfnDsl::Error, %r{^Invalid Reference:.*TestResource.*TestResource2})
      end

      it 'raises CfnDsl::Error if a resource explicitly DependsOn itself' do
        tr = subject.Resource(:TestResource)
        tr.Type('Custom-TestType')
        tr.DependsOn(['TestResource'])
        expect { subject.validate }.to raise_error(CfnDsl::Error, %r{TestResource.*references itself})
      end

      it 'raises CfnDsl::Error if a resource Refs itself' do
        tr = subject.Resource(:TestResource)
        tr.Type('Custom-TestType')
        tr.Property(:AProperty, tr.Ref(:TestResource))
        expect { subject.validate }.to raise_error(CfnDsl::Error, /TestResource.*itself/i)
      end

      it 'raises CfnDsl::Error if a resource references itself in Fn::GetAtt' do
        tr = subject.Resource(:TestResource)
        tr.Type('Custom-TestType')
        tr.Property(:AProperty, tr.FnGetAtt(:TestResource, :AnAttr))
        expect { subject.validate }.to raise_error(CfnDsl::Error, /TestResource.*itself/i)
      end

      it 'raises CfnDsl::Error if a resourcs references itself in Fn::Sub expression' do
        tr = subject.Resource(:TestResource)
        tr.Type('Custom-TestType')
        tr.Property(:AProperty, tr.FnSub('${TestResource}'))
        expect { subject.validate }.to raise_error(CfnDsl::Error, /TestResource.*itself/i)
      end

      it 'raises CfnDsl::Error if there are cyclic DependsOn references' do
        tr = subject.Resource(:ResourceOne)
        tr.Type('Custom-TestType')
        tr.DependsOn(:ResourceTwo)

        t2 = subject.Resource('ResourceTwo')
        t2.Type('Custom-TestType')
        t2.DependsOn(:ResourceOne)
        expect { subject.validate }.to raise_error(CfnDsl::Error, /cyclic.*ResourceTwo.*ResourceOne/i)
      end

      it 'raises CfnDsl::Error if there are cyclic Refs' do
        tr = subject.Resource(:TestResourceOne)
        tr.Type('Custom-TestType')
        tr.Property(:AProperty, tr.Ref(:TestResourceTwo))

        t2 = subject.Resource('TestResourceTwo')
        t2.Type('Custom-TestType')
        t2.DependsOn('TestResourceOne')
        expect { subject.validate }.to raise_error(CfnDsl::Error, /cyclic.*Two.*One/i)
      end

      it 'raises CfnDsl::Error if there are cyclic Fn::GetAtt references' do
        tr = subject.Resource(:TestResource1)
        tr.Property(:AProperty, tr.Ref(:TestResource2))

        t2 = subject.Resource('TestResource2')
        t2.DependsOn('TestResource3')

        t3 = subject.Resource('TestResource3')
        t3.Property(:OtherProperty, subject.FnGetAtt('TestResource1', :OtherAttribute))

        expect { subject.validate }.to raise_error(CfnDsl::Error, /cyclic.*3.*2.*1/i)
      end

      it 'raises CfnDsl::Error if there are cyclic Fn::Sub references' do
        subject.Resource(:TestResource1)

        t2 = subject.Resource('TestResource2')
        t2.DependsOn(%w[TestResource3 TestResource1])

        t3 = subject.Resource('TestResource3')
        t3.Property(:OtherProperty, subject.FnSub('SomeValue ${TestResource2}'))

        expect { subject.validate }.to raise_error(CfnDsl::Error, /cyclic*.3?.*2/i)
      end
    end

    context 'conditions' do
      it 'returns self if there are valid condition references' do
        subject.Parameter('TestParameter').Type('String')
        subject.Condition(:TestCondition, subject.FnEquals(subject.Ref(:TestParameter), 'testvalue'))
        expect(subject.validate).to equal(subject)
      end

      it 'raises CfnDsl::Error if invalid ref in condition' do
        subject.Condition(:TestCondition, subject.FnEquals(subject.Ref(:NoParam), 'testvalue'))
        expect { subject.validate }.to raise_error(CfnDsl::Error, %r{^Invalid Reference:.*TestCondition.*NoParam})
      end

      it 'raises CfnDsl::Error if null value in Condition' do
        subject.Condition(:TestCondition, subject.FnEquals(nil, 'testvalue'))
        expect { subject.validate }.to raise_error(CfnDsl::Error, %r{Condition.*TestCondition.*null})
      end

      it 'raises CfnDsl::Error if null value deep in Condition' do
        subject.Condition(:TestCondition, subject.FnEquals({ Condition: nil }, 'testvalue'))
        expect { subject.validate }.to raise_error(CfnDsl::Error, %r{Condition.*TestCondition.*null})
      end

      #Note cycles in conditions tested in cfndsl_spec.rb
    end

    context 'outputs' do
      it 'returns self if there are valid Refs to parameters' do
        subject.Parameter('TestParameter').Type('String')
        subject.Output('TestOutput').Value(subject.Ref(:TestParameter))
        expect(subject.validate).to equal(subject)
      end

      it 'returns self if there are valid Refs to resources' do
        subject.Resource(:TestResource)
        subject.Output('TestResourceOutput').Value(subject.Ref(:TestResource))
        expect(subject.validate).to equal(subject)
      end

      it 'returns self if there are valid Fn::GetAtt references to resources' do
        subject.Resource(:TestResource)
        subject.Output('TestResourceOutput').Value(subject.FnGetAtt(:TestResource, :AnAtt))
        expect(subject.validate).to equal(subject)
      end

      it 'raises CfnDsl::Error if references a non existent condition' do
        subject.Output(:TestOutput).Condition('NoCondition')
        expect { subject.validate }.to raise_error(CfnDsl::Error, /TestOutput.*NoCondition/)
      end

      it 'raises CfnDsl::Error if there are invalid Refs' do
        subject.Output('TestResourceOutput').Value(subject.Ref(:TestResource))
        expect { subject.validate }.to raise_error(CfnDsl::Error, %r{Outputs.*TestResource})
      end

      it 'raises CfnDsl::Error if there are invalid Fn::GetAtt references' do
        subject.Output('TestResourceOutput').Value(subject.FnGetAtt(:TestResource, :Attr))
        expect { subject.validate }.to raise_error(CfnDsl::Error, %r{Outputs.*TestResource})
      end

      it 'raises CfnDsl::Error if there are invalid Fn::Sub attribute references' do
        subject.Output('TestResourceOutput').Value(subject.FnSub('prefix ${SomeRef.attr}suffix'))
        expect { subject.validate }.to raise_error(CfnDsl::Error, %r{Outputs.*TestResource})
      end

      it 'raises CfnDsl::Error if there are invalid Fn::Sub references' do
        subject.Output('TestResourceOutput').Value(subject.FnSub('prefix ${SomeRef}suffix'))
        expect { subject.validate }.to raise_error(CfnDsl::Error, %r{Outputs.*TestResource})
      end
    end
  end
end

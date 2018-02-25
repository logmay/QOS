function swaps=swap2list(list1,list2)
swaps=[];
for ii=1:numel(list1)
    for jj=1:numel(list2)
        if list1(ii)==list2(jj) && ii~=jj
            swaps=[swaps;list1(ii),list1(jj)];
            temp=list1(ii);
            list1(ii)=list1(jj);
            list1(jj)=temp;
        end
    end
end

end
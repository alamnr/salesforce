var gGrid = {

    htmlDecode: function(s)
    {
        return jQuery('<div>').html(s).text();
    },

    refreshTotal: function($gridDiv,pageData)
    {
        var totalRow = {isTotal:true, pq_rowcls:'total'};
        var totalColumns = [];
        jQuery.each($gridDiv.pqGrid('getColModel'), function(i,col)
        {
            if(col.gTotal)
            {
                totalRow[col.dataIndx] = +0;
                totalColumns.push(col.dataIndx);
            }
            else
            {
                totalRow[col.dataIndx] = null;
            }
        });

        //aggregate the totals
        jQuery.each(pageData, function(i,row)
        {
            jQuery.each(totalColumns, function(j,dataIndx)
            {
                if(!isNaN(row[dataIndx]))
                    totalRow[dataIndx] += parseFloat(row[dataIndx]);
            });
        });

        if($gridDiv.find('.pq-grid-summary').length == 0)
            jQuery("<div class='pq-grid-summary'></div>").prependTo($gridDiv.find('.pq-grid-bottom'));
        $gridDiv.pqGrid("createTable", {data:[totalRow], $cont: $gridDiv.find('div.pq-grid-summary')});

        totalRow = null;
        totalColumns = null;  
    },

    refreshGrid_callback: function($gridDiv, listObj)
    {
    	//memorialize and clear the filter values
    	var filterValueOldObj = {};
    	var filterValueNewObj = {};
    	var filterValueNewArray = [];
        var data = [];

        jQuery.each($gridDiv.pqGrid('getColModel'), function(i,col)
        {
        	if(col.gFilter !== undefined && col.filter.value !== undefined && col.filter.value !== null && col.filter.value !== '')
        	{
        		//memorialize the filter value
        		filterValueOldObj[col.dataIndx] = col.filter.value;
        		//prepare to clear the filter value
        		filterValueNewObj[col.dataIndx] = '';
        		filterValueNewArray.push({dataIndx:col.dataIndx, value:''});
        	}
    		//for picklists, clear the options
    		if(col.gFilter !== undefined && col.filter.type == 'select')
    		{
				col.filter.cache = null;
				col.filter.options = [];    			
    		}        	
        });

        //clear all filter values, in order to ensure dataModel.data includes all data including filtered (hidden) data
        if(filterValueNewArray.length > 0)
        {
        	$gridDiv.pqGrid('filter',{oper:'replace',data:filterValueNewArray});
        }

        //update the grid data
        jQuery.each(listObj, function(i,obj)
        {
            data.push(obj.mapProperty);
        });
        $gridDiv.pqGrid('option','dataModel.data', data);

        //reset the filter options, and possibly restore the filter values
        if(listObj.length > 0)
        {
            jQuery.each($gridDiv.pqGrid('getColModel'), function(i,col)
            {
                if(col.gFilter !== undefined && col.filter.type == 'select')
                {
                    col.filter.cache = null;
                    col.filter.options = $gridDiv.pqGrid('getData',{dataIndx:[col.dataIndx]});

                    //if the old filter value is contained within the new options, use it
                    if(filterValueOldObj.hasOwnProperty(col.dataIndx))
                    {
                    	//retrieve the old value
                    	var oldValue = filterValueOldObj[col.dataIndx];

                    	//compare the old value to the list of options
	                    jQuery.each(col.filter.options, function (j,opt)
	                    {
	                    	//if they match, prepare to restore the filter value
	                    	if(opt[col.dataIndx] == oldValue)
	                    	{
	                    		filterValueNewObj[col.dataIndx] = oldValue;
	                    	}
	                    }); 
	                    oldValue = null;                   	
                    }
                }
                else if (col.gFilter !== undefined && col.filter.type == 'textbox' && filterValueOldObj.hasOwnProperty(col.dataIndx))
                {
                	filterValueNewObj[col.dataIndx] = filterValueOldObj[col.dataIndx];
                }
            });

	        //restore any filter values that can be restored
			filterValueNewArray = [];
			for(var k in filterValueNewObj) //k is a dataIndx of a column having a filter value to be set
			{
				if(filterValueNewObj.hasOwnProperty(k))
					filterValueNewArray.push({dataIndx:k, value:filterValueNewObj[k]});
			}

	        if(filterValueNewArray.length > 0)
	        {
	        	$gridDiv.pqGrid('filter',{oper:'replace',data:filterValueNewArray});
	        }
        }
        $gridDiv.pqGrid('refreshDataAndView');
        gSpinner.hide();

        //ensure garbage collection
    	filterValueOldObj = null;
    	filterValueNewObj = null;
    	filterValueNewArray = null
    	data = null;

        return; 
    },

    appendButtonClearFilters: function($gridDiv)
    {
        var $button = jQuery('<button type=\"button\" class=\"btn\">clear filters</button>');
            $button.on('click',function()
            {
            	gSpinner.show();
                gGrid.clearFilters($gridDiv);
                gSpinner.hide();
            });

        $gridDiv.find('div.pq-grid-title').append('&nbsp;&nbsp;');
        $gridDiv.find('div.pq-grid-title').append($button);

        $button = null;
    },

    clearFilters: function($gridDiv)
    {	
    	var filterValueNewArray = [];
        jQuery.each($gridDiv.pqGrid('getColModel'), function(i,col)
        {	
        	if(col.gFilter !== undefined && col.filter.value !== undefined && col.filter.value !== null && col.filter.value !== '')
        	{
        		filterValueNewArray.push({dataIndx:col.dataIndx, value:''});
        	}
        });
        if(filterValueNewArray.length > 0)
        {
        	$gridDiv.pqGrid('filter',{oper:'replace',data:filterValueNewArray});
        }

        $gridDiv.pqGrid('refreshDataAndView');

        filterValueNewArray = null;
    },

    appendButtonClearSelection: function($gridDiv)
    {
        var $button = jQuery('<button type=\"button\" class=\"btn\">clear selection</button>');
            $button.on('click',function()
            {
            	gSpinner.show();
                gGrid.clearSelection($gridDiv);
                gSpinner.hide();
            });

        $gridDiv.find('div.pq-grid-title').append('&nbsp;&nbsp;');
        $gridDiv.find('div.pq-grid-title').append($button);

        $button = null;
    },

    clearSelection: function($gridDiv)
    {
    	$gridDiv.pqGrid('selection',{type:'row',method:'removeAll'});
    },

    initFormat: function(colModel)
    {
        jQuery.each(colModel, function(i,col)
        {
            if(col.gFormat == 'number')
            {
                jQuery.extend(col,{
                    align:'center',
                    render: function(ui)
                    {
                        var cont = eval('ui.rowData.'+ui.dataIndx);
                        if (cont != null && !isNaN(cont))
                            return accounting.formatNumber(cont);
                    }
                });
            }
            else if(col.gFormat == 'money')
            {
                jQuery.extend(col,{
                    align:'right',
                    halign:'right',
                    render: function(ui)
                    {
                        var cont = eval('ui.rowData.'+ui.dataIndx);
                        if (cont && cont != null && !isNaN(cont))
                            return accounting.formatMoney(cont);
                    }
                });
            }
            else if(col.gFormat == 'checkbox')
            {
                jQuery.extend(col,{
                    align:'center',
                    halign:'center',
                    render: function(ui)
                    {
                        if(ui.rowData.pq_rowcls && ui.rowData.pq_rowcls.indexOf('total') >= 0) return;

                        var cont = eval('ui.rowData.'+ui.dataIndx);
                        var $wrap = jQuery('<wrap>').append(jQuery('<input>').attr('type','checkbox').attr('disabled','disabled'));

                        if(cont == 'true')
                        {
                            $wrap.children().first().attr('checked','checked');
                        }
                        cont = null;
                        var myHTML = $wrap.html();
                        $wrap = null;
                        return myHTML;
                    }
                });             
            }
        });
    },

    initFilter: function(colModel)
    {
        jQuery.each(colModel, function(i,col)
        {
            if(col.gFilter == true || col.gFilter == 'select')
            {
                jQuery.extend(col,{
                    filter:
                    {
                        type:'select',
                        condition: 'equal',
                        prepend: { '': '--All--' },
                        valueIndx: col.dataIndx,
                        labelIndx: col.dataIndx,
                        listeners: ['change'],
                        value:'',
                        cache:null,
                        options:null
                    }
                });
            }
            else if(col.gFilter == 'text')
            {
                jQuery.extend(col,{
                    filter: { type: 'textbox', condition: 'contain', listeners: ['keyup'] }
                });
            }
        });
    },

    appendExportLink: function($gridDiv)
    {
        var $exportLink = jQuery('<a download=\'export.xls\' href=\'#\'>Export to Excel</a>');
            $exportLink.on('click',function()
            {
                gGrid.export($gridDiv,this);
            });

        $gridDiv.find('div.pq-grid-title').append('&nbsp;&nbsp;');
        $gridDiv.find('div.pq-grid-title').append($exportLink);

        $exportLink = null;  
    },

    export: function($gridDiv,aTag)
    {
        gSpinner.show();

        var title = $gridDiv.pqGrid('option','title');

        var $rowTemplate = jQuery('<tr></tr>');
        var $header = jQuery('<tr></tr>');
        var $footer = jQuery('<tr></tr>');

        var dataIndexNumber = [];
        var dataIndexMoney = [];
        var totals = {};

        //build-up the header row
        //build-up a template detail row
        var titleColSpan = +0;
        jQuery.each($gridDiv.pqGrid('getColModel'), function(i,col)
        {
            var $newTD = jQuery('<td></td>');
            var $newTH = jQuery('<th style="border:1px solid black"></th>');
            //var $newTF = jQuery('<td style="font-weight:bold"></td>');
            if(!col.hidden && col.dataIndx != 'scrollSpacer')
            {
                $header.append($newTH.clone().addClass(col.dataIndx).html(col.title));
                $rowTemplate.append($newTD.clone().attr('id',col.dataIndx));

                titleColSpan += 1;
            }

            if(col.gFormat == 'money')
               dataIndexMoney.push(col.dataIndx);
            else if(col.gFormat == 'number')
               dataIndexNumber.push(col.dataIndx);

            if(col.gTotal == true)
               totals[col.dataIndx] = +0;

            $newTD = null;
            $newTH = null;
        });

        //create the table
        $table = jQuery('<table></table>');
        $table.attr('id','exportTable');

        //add the header row
        $table.append('<tr><td colspan=\"'+titleColSpan+'\" style="font-size:larger; font-weight:bold;">'+title+'</td></tr>');
        $table.append($header);

        //create and add the detail rows
        jQuery.each($gridDiv.pqGrid('option','dataModel.data'), function(i, dataRow){
            var $newRow = $rowTemplate.clone();
            
            if(dataRow.hasOwnProperty('pq_rowcls') && dataRow.pq_rowcls=='total')
            {
                $newRow.css('font-weight','bold');
            }

            jQuery.each($newRow.find('td'),function (j, cell){
                var idTd = jQuery(cell).attr('id');
                if(dataRow.hasOwnProperty(idTd))
                {
                    var cont = dataRow[idTd];

                    if(totals.hasOwnProperty(idTd) && !isNaN(cont))
                    	totals[idTd] = totals[idTd] + parseFloat(cont);
                    
                    if(jQuery.inArray(idTd,dataIndexMoney) >= 0 )
                        cont = accounting.formatMoney(cont);
                    else if(jQuery.inArray(idTd,dataIndexNumber) >= 0)
                        cont = accounting.formatNumber(cont);

                    if(dataRow.hasOwnProperty('pq_rowcls') && dataRow.pq_rowcls=='total' && cont==0){
                        jQuery(cell).html('').addClass(idTd).removeAttr('id');
                    } else {
                        jQuery(cell).html(cont).addClass(idTd).removeAttr('id');
                    }

                    cont = null;
                }
                idTd = null
            });

            $table.append($newRow);
            $newRow = null;
        });

		//build the total row
		var $totalRow = $rowTemplate.clone();
		$totalRow.css('font-weight','bold');

        jQuery.each($totalRow.find('td'),function (j, cell){
            var idTd = jQuery(cell).attr('id');
            if(totals.hasOwnProperty(idTd))
            {
                var cont = totals[idTd];
                
                if(jQuery.inArray(idTd,dataIndexMoney) >= 0 )
                    cont = accounting.formatMoney(cont);
                else if(jQuery.inArray(idTd,dataIndexNumber) >= 0)
                    cont = accounting.formatNumber(cont);

                jQuery(cell).html(cont).addClass(idTd).removeAttr('id');
                cont = null;
            }
            idTd = null;
        });

        $table.append($totalRow);

        var $exportStage = jQuery('<div></div>');
        $exportStage.append($table);
        jQuery(document.body).append($exportStage);
        ExcellentExport.excel(aTag, 'exportTable','');
        $exportStage.remove();

        //ensure garbage collection
        $rowTemplate = null;
        $header = null;
        $footer = null;
        $totalRow = null;
        $exportState = null;

        dataIndexNumber = null;
        dataIndexMoney = null;
        totals = null;

        gSpinner.hide();
    }
}
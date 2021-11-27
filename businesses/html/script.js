var active = false;

var gang_name
var business_id
var lead_members
var lead_ranks
var default_perms
var poss_invites
var pending_invites
var plyBusinesses
var businessTable

jconfirm.defaults = {
	icon: 'fas fa-briefcase',
	type: 'blue',
	theme: 'modern',
	columnClass: 'medium',
	closeIcon: true,
	typeAnimated: true,
};

$(function () {
	window.addEventListener('message', function (event) {
		document.body.style.display = event.data.enable ? "block" : "none";
		if (event.data.type == "create_menu") {
			if (active === false) {
				active = true;
				pending_invites = event.data.pending_invites
				plyBusinesses = event.data.player_Businesses
				businessTable = event.data.business_Table
				default_perms = event.data.default_perms
				create_menu()
			}
		// } else if (event.data.type == "lead_menu") {
		// 	if (active === false) {
		// 		active = true;
		// 		gang_name = event.data.gang_name
		// 		lead_members = event.data.gang_members
		// 		lead_ranks = event.data.gang_ranks
		// 		poss_invites = event.data.no_gangs
		// 		default_perms = event.data.default_permissions
		// 		lead_menu()
		// 	}
		} else if (event.data.type == "leave_menu") {
			if (active === false) {
				active = true;
				leave_menu()
			}
		}
	});
});

var selectedMember
function fetchSelectGangMember() {
	var x = document.getElementById("gang_lead_member_list").value;
	selectedMember = x
}

var selectedInvite
function fetchSelectInviteMember() {
	var x = document.getElementById("gang_lead_invite_list").value;
	selectedInvite = x
}

var selectedRank
function fetchSelectGangRank() {
	var x = document.getElementById("gang_lead_rank_list").value;
	selectedRank = x
}

var selectedRankProp
function fetchSelectGangPropRank() {
	var x = document.getElementById("gang_lead_rankProp_list").value;
	selectedRankProp = x
}

var selectedRankGrade
function fetchSelectGangGrade() {
	var x = document.getElementById("business_ranks").value;
	selectedRankGrade = x
	console.log(selectedRankGrade)
}

var selectedRankPerm
function fetchSelectGangRankPerm() {
	var x = document.getElementById("gang_lead_rankPerm_list").value;
	selectedRankPerm = x
}

var selectedBusiness
function fetchSelectBusinesses() {
	var x = document.getElementById("businesses").value;
	selectedBusiness = x
}

var selectedPendingInvite
function fetchSelectPendingInvite() {
	var x = document.getElementById("gang_pending_invites").value;
	selectedPendingInvite = x
}

function create_menu() {
	$.confirm({
		title: 'Business Menu',
		closeIcon: function () {
			$.post('https://businesses/escape', JSON.stringify({}));
			active = false;
		},
		content: 'Join and Manage a business here!<br>Select from the options below to proceed.' +
			'<br><br><strong>Manage Businesses:</strong>' +
			'<select name="cars" id="businesses" class="form-control ng-pristine ng-untouched ng-valid ng-not-empty" onchange="fetchSelectBusinesses()">' +
			'<option value="">None</option>' +
			'</select>',
		buttons: {
			acceptPendingInvite: {
				text: 'Pending Invitations',
				btnClass: 'btn-green',
				action: function () {
					$.confirm({
						title: 'Accept an Emploment Invitiation',
						autoClose: true,
						closeIcon: function () {
							$.post('https://businesses/escape', JSON.stringify({}));
							active = false;
						},
						content: '<br>Select from the business invitations below.<br><br>' +
						'<br><br><strong>Pending Invites</strong>' +
						'<select name="cars" id="gang_pending_invites" class="form-control ng-pristine ng-untouched ng-valid ng-not-empty" onchange="fetchSelectPendingInvite()">' +
						'<option value="">None</option>' +
						'</select>',
						buttons: {
							acceptInvite: {
								text: 'Accept',
								btnClass: 'btn-green',
								action: function () {
									if (!selectedPendingInvite) {
										$.alert('Select a pending invite!');
										return false;
									}
									$.post('https://businesses/accept_invite', JSON.stringify({ selectedPendingInvite }), function (postResult) {
										if (postResult.result == true) {
											$.alert({
												title: 'Business Invite Accepted!',
												content: postResult.message,
												type: 'green',
												buttons: {
													next: function () {
														$.post('https://businesses/escape', JSON.stringify({}));
														active = false;
													}
												}
											});
										} else {
											$.alert({
												title: 'Business Invite Failed!',
												content: postResult.message,
												type: 'red',
												buttons: {
													next: function () {
														$.post('https://businesses/escape', JSON.stringify({}));
														active = false;
													}
												}
											});

										}
									});
								}
							},
							goBack: {
								text: 'Return',
								btnClass: 'btn-orange',
								action: function () {
									create_menu()
								}
							},
						}
					});
				}
			},
			selectBusiness: {
				text: 'Manage Business',
				btnClass: 'btn-blue',
				action: function() {
					if (!selectedBusiness) {
						$.alert('Select a business!');
						return false;
					}
					business_id = businessTable[plyBusinesses[selectedBusiness]].name
					gang_name = businessTable[plyBusinesses[selectedBusiness]].label
					lead_members = businessTable[plyBusinesses[selectedBusiness]].members
					lead_ranks = businessTable[plyBusinesses[selectedBusiness]].grades
					poss_invites = "None"
					lead_menu()
				}
			},
/* 			createBusiness: {
				text: 'Create Business',
				btnClass: 'btn-success',
				action: function () {
					$.confirm({
						title: 'Create a Business',
						typeAnimated: true,
						icon: 'fas fa-briefcase',
						backgroundDismiss: true,
						autoClose: true,
						type: 'green',
						columnClass: 'medium',
						content: '' +
							'<form action="" class="formName">' +
							'<div class="form-group">' +
							'<label>By creating a Business you agree to all the server rules, found on the website roleplay.co.uk</label><label>For additional information for Business features please visit https://wiki.roleplay.co.uk/ prior to creating your Business!</label>' +
							'<input type="text" placeholder="Business Name" class="name form-control" required />' +
							'</div>' +
							'</form>',
						buttons: {
							formSubmit: {
								text: 'Create Business',
								btnClass: 'btn-success',
								action: function () {
									var name = this.$content.find('.name').val();
									if (!name) {
										$.alert('Please provide a valid Business name');
										return false;
									}

									$.post('https://businesses/create', JSON.stringify({ name }), function (ret_data) {
										if (ret_data.result == true) {
											$.alert({
												title: 'Business Creation Successful!',
												content: ret_data.message,
												icon: 'fas fa-briefcase',
												type: 'green',
												columnClass: 'medium',
												buttons: {
													next: function () {
														$.post('https://businesses/escape', JSON.stringify({}));
														active = false;
													}
												}
											});
										} else {
											$.alert({
												title: 'Business Creation Unsuccessful!',
												content: ret_data.message,
												icon: 'fas fa-briefcase',
												type: 'red',
												columnClass: 'medium',
												buttons: {
													next: function () {
														$.post('https://businesses/escape', JSON.stringify({}));
														active = false;
													}
												}
											});
										}
									});

								}
							},
							cancel: function () {
								$.post('https://businesses/escape', JSON.stringify({}));
								active = false;
							},
						},
						onContentReady: function () {
							var jc = this;
							this.$content.find('form').on('submit', function (e) {
								// if the user submits the form by pressing enter in the field.
								e.preventDefault();
								jc.$$formSubmit.trigger('click'); // reference the button and click it
							});
						}
					});
				}
			}, */
		},
		onContentReady: function () {
			$('#businesses').empty()
			$('#businesses').append('<option value=""></option>')
			for (let i in plyBusinesses) {
				let selected = plyBusinesses[i]
				$('#businesses').append('<option value="' + i + '">' + businessTable[selected].label + '</option>')
			}
			$('#gang_pending_invites').empty()
			$('#gang_pending_invites').append('<option value=""></option>')
			for (let i in pending_invites) {
				let invite = pending_invites[i]
				$('#gang_pending_invites').append('<option value="' + invite.gang_id + '">' + invite.gang_name + '</option>')
			}
		}
	});
}

function leave_menu() {
	$.confirm({
		title: 'Business Menu',
		icon: 'fas fa-briefcase',
		type: 'blue',
		theme: 'modern',
		content: 'You can use this menu to leave.',
		columnClass: 'medium',
		closeIcon: true,
		closeIcon: function () {
			$.post('https://businesses/escape', JSON.stringify({}));
			active = false;
		},
		buttons: {
			leaveGang: {
				text: 'Leave Business',
				btnClass: 'btn-red',
				action: function () {
					$.confirm({
						title: 'RPUK Business Menu',
						icon: 'fas fa-briefcase',
						type: 'red',
						content: 'Welcome to the Roleplay.co.uk Business interaction menu, as you are a employee of a Business. You can use this menu to leave.<br><br>',
						columnClass: 'medium',
						autoClose: 'cancel|10000',
						buttons: {
							leaveGang: {
								text: 'Leave Business',
								btnClass: 'btn-red',
								action: function () {

									$.post('https://businesses/leave', JSON.stringify({ name }), function (ret_data) {
										if (ret_data.result == true) {
											$.alert({
												title: 'You left the Business!',
												content: ret_data.message,
												icon: 'fas fa-briefcase',
												type: 'green',
												columnClass: 'medium',
												buttons: {
													next: function () {
														//$.post('https://businesses/escape', JSON.stringify({}));
														create_menu()
														active = false;
													}
												}
											});
										} else {
											$.alert({
												title: 'Something went wrong...',
												content: ret_data.message,
												icon: 'fas fa-briefcase',
												type: 'red',
												columnClass: 'medium',
												buttons: {
													next: function () {
														$.post('https://businesses/escape', JSON.stringify({}));
														active = false;
													}
												}
											});
										}
									});
								}
							},
							cancel: function () {
								leave_menu()
							}
						}
					});


				}
			},
		}
	});
}

function lead_menu() {
	$.confirm({
		title: 'Business Leadership',
		content: '<b>Current selection: ' + gang_name + '</b><br>',
		closeIcon: function () {
			$.post('https://businesses/escape', JSON.stringify({}));
			active = false;
		},
		buttons: {
			members: {
				text: 'Employees',
				action: function () {
					lead_menu_members()
				}
			},
/* 			invite: {
				text: 'Add Employee',
				action: function () {
					lead_menu_invite()
				}
			}, */
			ranks: {
				text: 'Ranks',
				action: function () {
					lead_menu_ranks()
				}
			},
/* 			disband: { // just make them leave
				text: 'Leave Business',
				btnClass: 'btn-danger',
				action: function () {
					leave_menu()
				}
			}, */
		}
	});
}

function lead_menu_members() {
	$.confirm({
		title: 'Business Employees',
		closeIcon: function () {
			$.post('https://businesses/escape', JSON.stringify({}));
			active = false;
		},
		content: '<b>Current selection: ' + gang_name + '</b><br><br>' +
			'<select name="cars" id="gang_lead_member_list" class="form-control ng-pristine ng-untouched ng-valid ng-not-empty" onchange="fetchSelectGangMember()">' +
			'<option value="">None</option>' +
			'</select>',
		buttons: {
			
			invite: {
				text: 'Add Employee',
				btnClass: 'btn-blue',
				action: function () {
					lead_menu_invite()
				}
			},

			changeRank: {
				text: 'Change Rank',
				btnClass: 'btn-blue',
				action: function () {
					if (!selectedMember) { // selectedMember = id
						$.alert('Please Select a Member');
						return false;
					}
					lead_menu_changeMemberRank(selectedMember)
				}
			},
			goBack: {
				text: 'Return',
				btnClass: 'btn-orange',
				action: function () {
					lead_menu()
				}
			},
		},

		onContentReady: function () {
			$('#gang_lead_member_list').empty()
			$('#gang_lead_member_list').append('<option value=""></option>')
			for (let i in lead_members) {
				let member = lead_members[i]
				// if (member.rank !== 1) { // exclude the leader from the member list
					var rank_label = "RANK NOT FOUND"
					// if (lead_ranks[member.rank - 1]) { rank_label = lead_ranks[member.rank - 1].label }
					$('#gang_lead_member_list').append('<option value="' + i + '">' + member.name + '</option>')
				// }
			}
		}
	});
}

function lead_menu_invite() {
	$.confirm({
		title: 'Add Employee',
		closeIcon: function () {
			$.post('https://businesses/escape', JSON.stringify({}));
			active = false;
		},
		content: '<b>Current selection: ' + gang_name + '</b><br><br>' +
			'<select name="cars" id="gang_lead_invite_list" class="form-control ng-pristine ng-untouched ng-valid ng-not-empty" onchange="fetchSelectInviteMember()">' +
			'<option value="">None</option>' +
			'</select>',
		buttons: {
			inviteMember: {
				text: 'Invite Employee',
				btnClass: 'btn-success',
				action: function () {
					if (!selectedInvite) { // selectedMember = id
						$.alert('Please Select Someone');
						return false;
					}
					$.post('https://businesses/invite', JSON.stringify({ selectedInvite }), function (ret_data) {
						if (ret_data.result == true) {
							$.alert({
								title: 'Employee Invited!',
								content: ret_data.message,
								type: 'green',
								buttons: {
									next: function () {
										//$.post('https://businesses/escape', JSON.stringify({}));
										poss_invites = JSON.parse(ret_data.no_gangs)
										lead_menu_invite()
										active = false;
									}
								}
							});
						} else {
							$.alert({
								title: 'Something went wrong...',
								content: "Something went wrong",//ret_data.message,
								type: 'red',
								buttons: {
									next: function () {
										$.post('https://businesses/escape', JSON.stringify({}));
										active = false;
									}
								}
							});
						}

					});

				}
			},
			goBack: {
				text: 'Return',
				btnClass: 'btn-orange',
				action: function () {
					lead_menu_members()
				}
			},
		},

		onContentReady: function () {
			$('#gang_lead_invite_list').empty()
			$('#gang_lead_invite_list').append('<option value=""></option>')
			for (let i in poss_invites) {
				let invite = poss_invites[i]
				$('#gang_lead_invite_list').append('<option value="' + i + '">' + invite.name + ' (No Affiliation)</option>')
			}
		}
	});
}

function lead_menu_changeMemberRank(charID) {
	var rank_label = "RANK NOT FOUND"
	if (lead_ranks[lead_members[charID].rank]) { rank_label = lead_ranks[lead_members[charID].rank].label }
	$.confirm({
		title: "Change " + lead_members[charID].name + "'s Rank <br><br> (Currently: " + rank_label + ")",
		closeIcon: function () {
			$.post('https://businesses/escape', JSON.stringify({}));
			active = false;
		},
		content: '<b>Current selection: ' + gang_name + '</b><br><br>' +
			'<select name="cars" id="gang_lead_rank_list" class="form-control ng-pristine ng-untouched ng-valid ng-not-empty" onchange="fetchSelectGangRank()">' +
			'<option value="">None</option>' +
			'</select>',
		buttons: {
			changeRank: {
				text: 'Change Rank',
				btnClass: 'btn-success',
				action: function () {
					if (!charID) { // selectedMember = id
						$.alert('Please Select a Member');
						return false;
					}
					$.post('https://businesses/alter_rank', JSON.stringify({ business_id, selectedRank, charID }), function (ret_data) {
						if (ret_data.result == true) {
							$.alert({
								title: 'Rank Changed!',
								content: ret_data.message,
								type: 'green',
								buttons: {
									next: function () {
										//$.post('https://businesses/escape', JSON.stringify({}));
										lead_menu()
										lead_members = JSON.parse(ret_data.gang_members)
										active = false;
									}
								}
							});
						} else {
							$.alert({
								title: 'Something went wrong...',
								content: ret_data.message,
								type: 'red',
								buttons: {
									next: function () {
										$.post('https://businesses/escape', JSON.stringify({}));
										active = false;
									}
								}
							});
						}

					});

				}
			},
			kickMember: {
				text: 'Fire',
				btnClass: 'btn-red',
				action: function () {
					if (!selectedMember) { // selectedMember = id
						$.alert('Please Select an Employee');
						return false;
					}
					$.confirm({
						title: 'Fire ' + lead_members[selectedMember].name,
						type: 'red',
						content: '',
						autoClose: 'cancel|10000',
						buttons: {
							kickMember2: {
								text: 'Fire Employee',
								btnClass: 'btn-red',
								action: function () {

									$.post('https://businesses/kick', JSON.stringify({ selectedMember }), function (ret_data) {
										if (ret_data.result == true) {
											$.alert({
												title: 'Employee fired!',
												content: "Employee Fired",//ret_data.message,
												type: 'green',
												buttons: {
													next: function () {
														//$.post('https://businesses/escape', JSON.stringify({}));
														lead_members = JSON.parse(ret_data.gang_members)
														lead_menu_members()
														active = false;
													}
												}
											});
										} else {
											$.alert({
												title: 'Something went wrong...',
												content: "Something went wrong",//ret_data.message,
												type: 'red',
												buttons: {
													next: function () {
														$.post('https://businesses/escape', JSON.stringify({}));
														active = false;
													}
												}
											});
										}
									});

								}
							},
							cancel: function () {
								lead_menu_members()
							}
						}
					});

				}
			},
			goBack: {
				text: 'Return',
				btnClass: 'btn-orange',
				action: function () {
					lead_menu_members()
				}
			},
		},

		onContentReady: function () {
			$('#gang_lead_rank_list').empty()
			$('#gang_lead_rank_list').append('<option value=""></option>')
			for (let i in lead_ranks) {
				let rank = lead_ranks[i]
				$('#gang_lead_rank_list').append('<option value="' + i + '">' + rank.label + '</option>')
			}
		}
	});
}

function lead_menu_ranks() {
	$.confirm({
		title: 'Rank Properties ',
		closeIcon: function () {
			$.post('https://businesses/escape', JSON.stringify({}));
			active = false;
		},
		content: '<b>Current selection: ' + gang_name + '</b><br><br>' +
			'<select name="cars" id="gang_lead_rankProp_list" class="form-control ng-pristine ng-untouched ng-valid ng-not-empty" onchange="fetchSelectGangPropRank()">' +
			'<option value="">None</option>' +
			'</select>',
		buttons: {
			editRank: {
				text: 'Edit Rank',
				btnClass: 'btn-blue',
				action: function () {
					if (!selectedRankProp) {
						$.alert('Please Select a Rank');
						return false;
					}
					$.confirm({
						title: 'Editing Rank: ' + lead_ranks[selectedRankProp].label,
						content: '' +
							'<form action="" class="formName">' +
							'<div class="form-group">' +
							'<label><strong>Ensure you read the community rules.</strong></label><br>' +
							'<label for="label">Rank Name:<input type="text" id="label" name="label" value="'+lead_ranks[selectedRankProp].label+'" class="new_name form-control" required /></label>' +
							'<label>Rank Paycheck:<input type="number" name="salary" value="'+lead_ranks[selectedRankProp].salary+'" min="0" step="25" class="new_salary form-control" required /></label>' +
							'<label>Select Rank Position<select name="cars" id="business_ranks" class="form-control ng-pristine ng-untouched ng-valid ng-not-empty" onchange="fetchSelectGangGrade()"></label>' +
							'<option value="">None</option>' +
							'</div>' +
							'<div class="form-group">'+
							'<p>Permissions:</p>',
						buttons: {			
							formSubmit: {
								text: 'Submit',
								btnClass: 'btn-success',
								action: function () {
/* 									var adminChecked = this.$content.find('.business_mng_admin').is(":checked")
									var adminExisted = lead_ranks[selectedRankProp].permissions.includes('business_mng_admin')

									if (!adminChecked && adminExisted) {
										$.confirm({
											title: 'WARNING',
											content: 'YOU ARE ABOUT TO REMOVE ADMIN PERMISSIONS, ENSURE ANOTHER RANK STILL HOLDS THIS PERMISSION!',
											autoClose: 'cancel|5000',
											buttons: {
												confirm: {
													text: 'Confirm',
													btnClass: 'btn-success',
													action: function () {
														return true;
													}
												},
												cancel: {
													text: 'Cancel',
													btnClass: 'btn-danger',
													action: function () {
														return false;
													}
												}
											}
										});
									} */
									var new_name = this.$content.find('.new_name').val();
									if (!new_name) {
										$.alert('Provide a valid name');
										return false;
									}
									var new_salary = this.$content.find('.new_salary').val();
									if (new_salary < 0) {
										$.alert('Paycheck must be above 0');
										return false;
									}
									var new_grade = this.$content.find('.new_grade').val();
									updatedRank = {}
									updatedRank.label = new_name
									updatedRank.salary = new_salary
									updatedRank.grade = selectedRankGrade
									updatedRank.permissions = []
									for (let i in default_perms) {
										var perm = this.$content.find('.'+i).is(":checked")
										if (perm) {
											updatedRank.permissions.push(i)
										} 
									}
									$.post('https://businesses/update_rank', JSON.stringify({ business_id, selectedRankProp, updatedRank }), function (ret_data) {
										if (ret_data.result == true) {
											$.alert({
												title: 'Rank Updated!',
												content: ret_data.message,
												type: 'green',
												buttons: {
													next: function () {
														lead_ranks = JSON.parse(ret_data.gang_ranks)
														lead_menu_ranks()
														active = false;
													}
												}
											});
										} else {
											$.alert({
												title: 'Something went wrong...',
												content: ret_data.message,
												type: 'red',
												buttons: {
													next: function () {
														$.post('https://businesses/escape', JSON.stringify({}));
														active = false;
													}
												}
											});
										}
									});
								}
							},
							deleteRank: {
								text: 'Delete Rank',
								btnClass: 'btn-red',
								action: function () {
									$.confirm({
										title: 'Menu',
										type: 'red',
										content: 'Members in this rank will be moved to the lowest available rank.<br><strong>You are about to delete the rank: ' + lead_ranks[selectedRankProp].label + '</strong>',
										autoClose: 'cancel|10000',
										buttons: {
											leaveGang: {
												text: 'Delete Rank',
												btnClass: 'btn-red',
												action: function () {

													$.post('https://businesses/delete_rank', JSON.stringify({ selectedRankProp }), function (ret_data) {
														if (ret_data.result == true) {
															$.alert({
																title: 'Rank Deleted!',
																content: ret_data.message,
																type: 'green',
																buttons: {
																	next: function () {
																		lead_ranks = JSON.parse(ret_data.gang_ranks)
																		lead_menu_ranks()
																		active = false;
																	}
																}
															});
														} else {
															$.alert({
																title: 'Something went wrong...',
																content: ret_data.message,
																type: 'red',
																buttons: {
																	next: function () {
																		$.post('https://businesses/escape', JSON.stringify({}));
																		active = false;
																	}
																}
															});
														}
													});
												}
											},
											cancel: function () {
												lead_menu_ranks()
											}
										}
									});


								}
							}, 
							cancel: function () {
								lead_menu_ranks()
							},
						},
						onContentReady: function () {
							for (let i in default_perms) {
								let permission = default_perms[i]
								let hasPerm = ""
								for (let a in lead_ranks[selectedRankProp].permissions) {
									let inPerms = lead_ranks[selectedRankProp].permissions[a]
									if (i === inPerms) {
										hasPerm = "checked"
									}
								}
								this.setContentAppend('<input type="checkbox" id="'+i+'" name="'+i+'"'+hasPerm+' class='+i+'>'+
								'<label for="'+i+'">	'+ permission[0]+'</label><br>')
							}
							
							$('#business_ranks').empty()
							$('#business_ranks').append('<option value="'+ -1 +'"> No Change </option>')
							let prevRank = ''
							for (let i in lead_ranks) {
								let rank = lead_ranks[i]
								id = i
								if (i > selectedRankProp) {
									id = i -1
								}
								if (i!=selectedRankProp) {
									if (i!=0) {
										$('#business_ranks').append('<option value="' + id + '">Between: ' +prevRank.label + ' & ' + rank.label + '</option>')
									}
									prevRank = lead_ranks[i]
								}
							}
							var jc = this;
							this.$content.find('form').on('submit', function (e) {
								e.preventDefault();
								jc.$$formSubmit.trigger('click');
							});
						}
					});
					//

				}
			},newRank: {
				text: 'Create Rank',
				btnClass: 'btn-blue',
				action: function () {
					$.confirm({
						title: 'Create Rank',
						content:  '' +
						'<form action="" class="formName">' +
						'<div class="form-group">' +
						'<label><strong>Ensure you read the community rules.</strong></label><br>' +
						'<label for="label">Rank Name:<input type="text" id="label" name="label" value="" class="new_name form-control" required /></label>' +
						'<label>Rank Paycheck:<input type="number" name="salary" value="" min="0" step="25" class="new_salary form-control" required /></label>' +
						'<label>Rank Grade:<input type="number" value="" class="new_grade form-control" required /></label>' +
						'</div>' +
						'<div class="form-group">'+
						'<p>Permissions:</p>',
						buttons: {
							formSubmit: {
								text: 'Submit',
								btnClass: 'btn-success',
								action: function () {
									var new_name = this.$content.find('.new_name').val();
									if (!new_name) {
										$.alert('Provide a valid name');
										return false;
									}
									var new_salary = this.$content.find('.new_salary').val();
									if (new_salary < 0) {
										$.alert('Paycheck must be above 0');
										return false;
									}
									var new_grade = this.$content.find('.new_grade').val();
									updatedRank = {}
									updatedRank.label = new_name
									updatedRank.salary = new_salary
									updatedRank.grade = new_grade
									updatedRank.permissions = []
									for (let i in default_perms) {
										var perm = this.$content.find('.'+i).is(":checked")
										if (perm) {
											updatedRank.permissions.push(i)
										} 
									}
									$.post('https://businesses/create_gang_rank', JSON.stringify({ new_name }), function (ret_data) {
										if (ret_data.result == true) {
											$.alert({
												title: 'New Rank Created!',
												content: ret_data.message,
												type: 'green',
												buttons: {
													next: function () {
														lead_ranks = JSON.parse(ret_data.gang_ranks)
														lead_menu_ranks()
														active = false;
													}
												}
											});
										} else {
											$.alert({
												title: 'Something went wrong...',
												content: ret_data.message,
												type: 'red',
												buttons: {
													next: function () {
														$.post('https://businesses/escape', JSON.stringify({}));
														active = false;
													}
												}
											});
										}
									});
								}
							},
			
							cancel: function () {
								lead_menu_ranks()
							},
						},
						onContentReady: function () {
							for (let i in default_perms) {
								let permission = default_perms[i]
								let hasPerm = ""
								this.setContentAppend('<input type="checkbox" id="'+i+'" name="'+i+'"'+hasPerm+' class='+i+'>'+
								'<label for="'+i+'">	'+ permission[0]+'</label><br>')
							}
							var jc = this;
							this.$content.find('form').on('submit', function (e) {
								e.preventDefault();
								jc.$$formSubmit.trigger('click');
							});
						}
					});
				}
			},
goBack: {
				text: 'Return',
				btnClass: 'btn-orange',
				action: function () {
					lead_menu()
				}
			},
		},

		onContentReady: function () {
			$('#gang_lead_rankProp_list').empty()
			$('#gang_lead_rankProp_list').append('<option value=""></option>')
			for (let i in lead_ranks) {
				let rank = lead_ranks[i]
				$('#gang_lead_rankProp_list').append('<option value="' + i + '">' + rank.label + '</option>')
			}
		}
	});
}

function lead_menu_ranks_old() {
	$.confirm({
		title: 'Rank Properties ',
		closeIcon: function () {
			$.post('https://businesses/escape', JSON.stringify({}));
			active = false;
		},
		content: '<b>Current selection: ' + gang_name + '</b><br><br>' +
			'<select name="cars" id="gang_lead_rankProp_list" class="form-control ng-pristine ng-untouched ng-valid ng-not-empty" onchange="fetchSelectGangPropRank()">' +
			'<option value="">None</option>' +
			'</select>',
		buttons: {
			changeLabel: {
				text: 'Change Label',
				btnClass: 'btn-blue',
				action: function () {
					if (!selectedRankProp) {
						$.alert('Please Select a Rank');
						return false;
					}

					//
					$.confirm({
						title: 'Change Rank Label (Currently: ' + lead_ranks[selectedRankProp].label + ')',
						content: '' +
							'<form action="" class="formName">' +
							'<div class="form-group">' +
							'<label>Enter an appropriate rank name.<br><strong>Ensure you read the community rules.</strong></label>' +
							'<input type="text" placeholder="Gang Label" class="new_name form-control" required />' +
							'</div>' +
							'</form>',
						buttons: {
							formSubmit: {
								text: 'Submit',
								btnClass: 'btn-success',
								action: function () {
									var new_name = this.$content.find('.new_name').val();
									if (!new_name) {
										$.alert('Provide a valid name');
										return false;
									}
									$.post('https://businesses/alter_rank_label', JSON.stringify({ business_id, selectedRankProp, new_name }), function (ret_data) {
										if (ret_data.result == true) {
											$.alert({
												title: 'Rank Label Changed!',
												content: ret_data.message,
												type: 'green',
												buttons: {
													next: function () {
														lead_ranks = JSON.parse(ret_data.gang_ranks)
														lead_menu_ranks()
														active = false;
													}
												}
											});
										} else {
											$.alert({
												title: 'Something went wrong...',
												content: ret_data.message,
												type: 'red',
												buttons: {
													next: function () {
														$.post('https://businesses/escape', JSON.stringify({}));
														active = false;
													}
												}
											});
										}
									});
								}
							},
							cancel: function () {
								lead_menu_ranks()
							},
						},
						onContentReady: function () {
							var jc = this;
							this.$content.find('form').on('submit', function (e) {
								e.preventDefault();
								jc.$$formSubmit.trigger('click');
							});
						}
					});
					//

				}
			},
			togglePermission: {
				text: 'Change Permission',
				btnClass: 'btn-blue',
				action: function () {
					if (!selectedRankProp) {
						$.alert('Please Select a Rank');
						return false;
					}

					//
					$.confirm({
						title: "Change " + lead_ranks[selectedRankProp].label + "'s Permissions",
						closeIcon: function () {
							$.post('https://businesses/escape', JSON.stringify({}));
							active = false;
						},
						content: '' +
							'<select name="cars" id="gang_lead_rankPerm_list" class="form-control ng-pristine ng-untouched ng-valid ng-not-empty" onchange="fetchSelectGangRankPerm()">' +
							'<option value="">None</option>' +
							'</select>',
						buttons: {
							togglePerm: {
								text: 'Toggle Permission',
								btnClass: 'btn-success',
								action: function () {
									if (!selectedRankPerm) { // selectedMember = id
										$.alert('Please Select a Permission');
										return false;
									}
									$.post('https://businesses/alter_rank_permission', JSON.stringify({ business_id, selectedRankProp, selectedRankPerm }), function (ret_data) {
										if (ret_data.result == true) {
											$.alert({
												title: 'Rank Permission Changed!',
												content: ret_data.message,
												type: 'green',
												buttons: {
													next: function () {
														lead_ranks = JSON.parse(ret_data.gang_ranks)
														lead_menu_ranks()
														active = false;
													}
												}
											});
										} else {
											$.alert({
												title: 'Something went wrong...',
												content: ret_data.message,
												type: 'red',
												buttons: {
													next: function () {
														$.post('https://businesses/escape', JSON.stringify({}));
														active = false;
													}
												}
											});
										}
									});
								}
							},
							goBack: {
								text: 'Return',
								btnClass: 'btn-orange',
								action: function () {
									lead_menu_ranks()
								}
							},
						},

						onContentReady: function () {
							$('#gang_lead_rankPerm_list').empty()
							$('#gang_lead_rankPerm_list').append('<option value=""></option>')
							for (let i in default_perms) {
								let permission = default_perms[i]
								let hasPerm = "pink"
								for (let a in lead_ranks[selectedRankProp].permissions) {
									let inPerms = lead_ranks[selectedRankProp].permissions[a]
									if (i === inPerms) {
										hasPerm = "lightgreen"
									}
								}
								$('#gang_lead_rankPerm_list').append('<option style="background:' + hasPerm + ';color:black;" value="' + i + '">' + permission[0] + '</option>')
							}
						}
					});
				}
			},
			newRank: {
				text: 'Create Rank',
				btnClass: 'btn-blue',
				action: function () {
					$.confirm({
						title: 'Create Rank',
						content: '' +
							'<form action="" class="formName">' +
							'<div class="form-group">' +
							'<label>Enter an appropriate rank name.<br><strong>Ensure you read the community rules.</strong></label>' +
							'<input type="text" placeholder="Gang Label" class="new_name form-control" required />' +
							'</div>' +
							'</form>',
						buttons: {
							formSubmit: {
								text: 'Submit',
								btnClass: 'btn-success',
								action: function () {
									var new_name = this.$content.find('.new_name').val();
									if (!new_name) {
										$.alert('Provide a valid name');
										return false;
									}
									$.post('https://businesses/create_gang_rank', JSON.stringify({ new_name }), function (ret_data) {
										if (ret_data.result == true) {
											$.alert({
												title: 'New Rank Created!',
												content: ret_data.message,
												type: 'green',
												buttons: {
													next: function () {
														lead_ranks = JSON.parse(ret_data.gang_ranks)
														lead_menu_ranks()
														active = false;
													}
												}
											});
										} else {
											$.alert({
												title: 'Something went wrong...',
												content: ret_data.message,
												type: 'red',
												buttons: {
													next: function () {
														$.post('https://businesses/escape', JSON.stringify({}));
														active = false;
													}
												}
											});
										}
									});
								}
							},
							cancel: function () {
								lead_menu_ranks()
							},
						},
						onContentReady: function () {
							var jc = this;
							this.$content.find('form').on('submit', function (e) {
								e.preventDefault();
								jc.$$formSubmit.trigger('click');
							});
						}
					});
				}
			},
			deleteRank: {
				text: 'Delete Rank',
				btnClass: 'btn-red',
				action: function () {
					$.confirm({
						title: 'Menu',
						type: 'red',
						content: 'Members in this rank will be moved to the lowest available rank.<br><strong>You are about to delete the rank: ' + lead_ranks[selectedRankProp].label + '</strong><br><br><strong>Ensure you are not in active roleplay scenario.</strong>',
						autoClose: 'cancel|10000',
						buttons: {
							leaveGang: {
								text: 'Delete Rank',
								btnClass: 'btn-red',
								action: function () {

									$.post('https://businesses/delete_gang_rank', JSON.stringify({ selectedRankProp }), function (ret_data) {
										if (ret_data.result == true) {
											$.alert({
												title: 'Rank Deleted!',
												content: ret_data.message,
												type: 'green',
												buttons: {
													next: function () {
														lead_ranks = JSON.parse(ret_data.gang_ranks)
														lead_menu_ranks()
														active = false;
													}
												}
											});
										} else {
											$.alert({
												title: 'Something went wrong...',
												content: ret_data.message,
												type: 'red',
												buttons: {
													next: function () {
														$.post('https://businesses/escape', JSON.stringify({}));
														active = false;
													}
												}
											});
										}
									});
								}
							},
							cancel: function () {
								lead_menu_ranks()
							}
						}
					});


				}
			},
			goBack: {
				text: 'Return',
				btnClass: 'btn-orange',
				action: function () {
					lead_menu()
				}
			},
		},

		onContentReady: function () {
			$('#gang_lead_rankProp_list').empty()
			$('#gang_lead_rankProp_list').append('<option value=""></option>')
			for (let i in lead_ranks) {
				let rank = lead_ranks[i]
				$('#gang_lead_rankProp_list').append('<option value="' + i + '">' + rank.label + '</option>')
			}
		}
	});
}
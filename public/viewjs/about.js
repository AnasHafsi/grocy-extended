$('[data-toggle="collapse-next"]').on("click", function(e)
{
	e.preventDefault();
	$(this).parent().next().collapse("toggle");
});

if ((typeof GetUriParam("tab") !== "undefined" && GetUriParam("tab") === "changelog"))
{
	$(".nav-tabs a[href='#changelog']").tab("show");
}

// Fork build time is shown with full "X minutes/hours ago" precision, not the
// day-bucketed "Today"/"Yesterday" that RefreshContextualTimeago gives other
// dates on this page - builds happen multiple times a day during active work,
// so knowing it was 5 minutes ago vs. this morning actually matters here.
var forkBuildTime = $("#fork-build-time");
if (forkBuildTime.length && forkBuildTime.attr("datetime"))
{
	forkBuildTime.text(moment(forkBuildTime.attr("datetime")).fromNow());
}

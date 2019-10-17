package actions

EventConfig :: {
	check_run?: {
		type =
		"created" |
		"rerequested" |
		"completed" |
		"requested_action"
		types?: [ ... type]
	}
	check_suite?: {
		type =
		"assigned" |
		"unassigned" |
		"labeled" |
		"unlabeled" |
		"opened" |
		"edited" |
		"closed" |
		"reopened" |
		"synchronize" |
		"ready_for_review" |
		"locked" |
		"unlocked " |
		"review_requested " |
		"review_request_removed"
		types?: [ ... type]
	}
	issue_comment?: {
		type =
		"created" |
		"edited" |
		"deleted"
		types?: [ ... type]
	}
	issues?: {
		type =
		"opened" |
		"edited" |
		"deleted" |
		"transferred" |
		"pinned" |
		"unpinned" |
		"closed" |
		"reopened" |
		"assigned" |
		"unassigned" |
		"labeled" |
		"unlabeled" |
		"locked" |
		"unlocked" |
		"milestoned" |
		"demilestoned"
		types?: [ ... type]
	}
	label?: {
		type =
		"created" |
		"edited" |
		"deleted"
		types?: [ ... type]
	}
	member?: {
		type =
		"added" |
		"edited" |
		"deleted"
		types?: [ ... type]
	}
	milestone?: {
		type =
		"created" |
		"closed" |
		"opened" |
		"edited" |
		"deleted"
		types?: [ ... type]
	}
	project?: {
		type =
		"created" |
		"closed" |
		"opened" |
		"edited" |
		"deleted"
		types?: [ ... type]
	}
	project_card?: {
		type =
		"created" |
		"moved" |
		"converted" |
		"edited" |
		"deleted"
		types?: [ ... type]
	}
	project_column?: {
		type =
		"created" |
		"updated" |
		"moved" |
		"deleted"
		types?: [ ... type]
	}
	pull_request?: {
		PushPullEvent
		type =
		"assigned" |
		"unassigned" |
		"labeled" |
		"unlabeled" |
		"opened" |
		"edited" |
		"closed" |
		"reopened" |
		"synchronize" |
		"ready_for_review" |
		"locked" |
		"unlocked " |
		"review_requested " |
		"review_request_removed"
		types?: [ ... type]
	}
	pull_request_review?: {
		type =
		"submitted" |
		"edited" |
		"dismissed"
		types?: [ ... type]
	}
	pull_request_review_comment?: {
		type =
		"created" |
		"edited" |
		"deleted"
		types?: [ ... type]
	}
	push?: {
		PushPullEvent
	}
	release?: {
		type =
		"published " |
		"unpublished " |
		"created " |
		"edited " |
		"deleted " |
		"prereleased"
		types? : [ ... type]
	}
	// schedule configures a workflow to run at specific UTC times using POSIX
	// cron syntax. Scheduled workflows run on the latest commit on the
	// default or base branch.
	schedule?: [{
		// cron specifies the time schedule in cron syntax.
		// See https://help.github.com/en/articles/events-that-trigger-workflows#scheduled-events
		// TODO regexp for cron syntax
		cron: string
	}]
	watch?: {
		types?: [ "started"]
	}
}

PushPullEvent :: {
	branches?: [... Glob]
	tags?: [... Glob]
	"branches-ignore"?: [... Glob]
	"tags-ignore"?: [... Glob]
	paths?: [... Glob]
}

Event ::
	"issues" |
	"check_run" |
	"check_suite" |
	"commit_comment" |
	"create" |
	"delete" |
	"deployment" |
	"deployment_status" |
	"fork" |
	"gollum" |
	"issue_comment" |
	"issues" |
	"label" |
	"member" |
	"milestone" |
	"page_build" |
	"project" |
	"project_card" |
	"project_column" |
	"public" |
	"pull_request" |
	"pull_request_review" |
	"pull_request_review_comment" |
	"push" |
	"release" |
	"status" |
	"watch" |
	"schedule" |
	"repository_dispatch"

// Glob represents a wildcard pattern.
// See https://help.github.com/en/articles/workflow-syntax-for-github-actions#filter-pattern-cheat-sheet
Glob :: string

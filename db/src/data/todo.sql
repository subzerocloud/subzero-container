create table todo (
	id    serial primary key,
	todo  text not null,
	private boolean default true,  
	owner_id int references "user"(id) default request.user_id()
);

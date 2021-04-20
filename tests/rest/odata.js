import { odata_service, resetdb } from '../common'
import should from 'should'
describe('odata', function () {
  before(function (done) { resetdb(); done() })
  after(function (done) { resetdb(); done() })

  it('basic', function (done) {
    odata_service()
      .get('/Todos?select=id,todo')
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        //console.log(r.body)
        r.body.value.length.should.equal(3)
        r.body.value[0].id.should.equal('dG9kbzox')
      })
  })

  it('by primary key', function (done) {
    odata_service()
      .get('/Todos(1)?select=id,todo')
      .expect(200, done)
      .expect(r => {
        //console.log(r.body)
        r.body.id.should.equal('dG9kbzox')
        r.body.todo.should.equal('item_1')
      })
  })
})